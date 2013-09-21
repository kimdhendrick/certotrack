class EmployeeDeactivationController < ApplicationController

  before_filter :authenticate_user!,
                :load_equipment_service,
                :load_employee_deactivation_service,
                :load_certification_service

  before_action :_set_employee, only: [:deactivate_confirm, :deactivate]

  check_authorization

  def deactivate_confirm
    @equipments = @equipment_service.get_all_equipment_for_employee(@employee)
    @certifications = @certification_service.get_all_certifications_for_employee(@employee)
  end

  def deactivate
    authorize! :read, :certification

    @employee_deactivation_service.deactivate_employee(@employee)
    redirect_to employees_url, notice: "Employee #{@employee} deactivated"
  end

  def deactivated_employees
    authorize! :read, :certification

    @employees = @employee_deactivation_service.get_deactivated_employees(current_user, params)
    @employee_count = @employees.count
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

  def _set_employee
    employee_pending_authorization = Employee.find(params[:id])
    authorize! :manage, employee_pending_authorization
    @employee = employee_pending_authorization
  end
end