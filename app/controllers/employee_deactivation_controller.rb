class EmployeeDeactivationController < ApplicationController

  before_filter :authenticate_user!, :load_equipment_service, :load_employee_deactivation_service

  before_action :_set_employee, only: [:deactivate_confirm, :deactivate]

  def deactivate_confirm
    @equipments = @equipment_service.get_all_equipment_for_employee(@employee)
  end

  def deactivate
    @employee_deactivation_service.deactivate_employee(@employee)
    redirect_to employees_url, notice: "Employee #{@employee} deactivated"
  end

  def load_employee_deactivation_service(service = EmployeeDeactivationService.new)
    @employee_deactivation_service ||= service
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end

  private

  def _set_employee
    employee_pending_authorization = Employee.find(params[:id])
    authorize! :manage, employee_pending_authorization
    @employee = employee_pending_authorization
  end
end