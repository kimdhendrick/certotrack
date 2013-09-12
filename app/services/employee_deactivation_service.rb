class EmployeeDeactivationService

  def initialize(params = {})
    @equipment_service = params[:equipment_service] || EquipmentService.new
    @paginator = params[:paginator] || Paginator.new
  end

  def deactivate_employee(employee)
    @equipment_service.get_all_equipment_for_employee(employee).each do |equipment|
      equipment.employee = nil
      equipment.save
    end

    employee.deactivation_date = Date.today
    employee.active = false
    employee.save
  end

  def get_deactivated_employees(current_user, params = {})
    employees = current_user.admin? ?
      Employee.unscoped.where(active: false) :
      Employee.unscoped.where(active: false, customer: current_user.customer)

    @paginator.paginate(employees, params[:page])
  end
end