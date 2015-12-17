class EmployeeDeactivationController < ModelController
  include ControllerHelper

  before_filter :load_equipment_service,
                :load_employee_deactivation_service,
                :load_employee_reactivation_service,
                :load_certification_service

  before_action :_set_employee, only: [:deactivate_confirm, :deactivate]

  def deactivate_confirm
    @equipments = EquipmentListPresenter.new(@equipment_service.get_all_equipment_for_employee(@employee)).sort
    @certifications = CertificationListPresenter.new(@certification_service.get_all_certifications_for_employee(@employee)).sort
  end

  def deactivate
    authorize! :read, :certification

    @employee_deactivation_service.deactivate_employee(@employee)
    flash[:success] = "Employee #{EmployeePresenter.new(@employee).name} deactivated"
    redirect_to employees_url
  end

  def reactivate
    @employee = _get_model(Employee, unscoped: true)
    @employee_reactivation_service.reactivate_employee(@employee)
    flash[:success] = "Employee #{EmployeePresenter.new(@employee).name} reactivated"
    redirect_to @employee
  end

  def deactivated_employees
    authorize! :read, :certification

    employee_collection = @employee_deactivation_service.get_deactivated_employees(current_user)
    report_title = 'Deactivated Employee List'
    report_type = 'deactivated_employees'

    respond_to do |format|
      format.html { _render_collection_as_html(employee_collection) }
      format.csv { _render_collection_as_csv(report_type, employee_collection) }
      format.xls { _render_collection_as_xls(report_title, report_type, employee_collection) }
      format.pdf { _render_collection_as_pdf(report_title, report_type, employee_collection) }
    end
  end

  def load_employee_deactivation_service(service = EmployeeDeactivationService.new)
    @employee_deactivation_service ||= service
  end

  def load_employee_reactivation_service(service = EmployeeReactivationService.new)
    @employee_reactivation_service ||= service
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end

  private

  def _render_collection_as_html(employee_collection)
    @employees = EmployeeListPresenter.new(employee_collection).present(params)
    @employee_count = employee_collection.count
  end

  def _set_employee
    @employee = _get_model(Employee)
  end
end