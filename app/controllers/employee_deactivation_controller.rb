class EmployeeDeactivationController < ModelController
  include ControllerHelper

  before_filter :load_equipment_service,
                :load_employee_deactivation_service,
                :load_certification_service

  before_action :_set_employee, only: [:deactivate_confirm, :deactivate]

  def deactivate_confirm
    @equipments = EquipmentListPresenter.new(@equipment_service.get_all_equipment_for_employee(@employee)).present
    @certifications = CertificationListPresenter.new(@certification_service.get_all_certifications_for_employee(@employee)).present
  end

  def deactivate
    authorize! :read, :certification

    @employee_deactivation_service.deactivate_employee(@employee)
    redirect_to employees_url, notice: "Employee #{EmployeePresenter.new(@employee).name} deactivated"
  end

  def deactivated_employees
    authorize! :read, :certification

    employee_collection = @employee_deactivation_service.get_deactivated_employees(current_user)

    respond_to do |format|
      format.html { _render_collection_as_html(employee_collection) }
      format.csv { _render_collection_as_csv(employee_collection, nil) }
      format.xls { _render_collection_as_xls('Deactivated Employee List', nil, employee_collection) }
      format.pdf { _render_collection_as_pdf('Deactivated Employee List', nil, employee_collection) }
    end
  end

  def load_employee_deactivation_service(service = EmployeeDeactivationService.new)
    @employee_deactivation_service ||= service
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

  def _sort_params
    {}
  end

  def _filename(_, extension)
    "deactivated_employees.#{extension}"
  end

  def _set_employee
    @employee = _get_model(Employee)
  end
end