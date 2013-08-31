class EmployeeDeactivationService
  def deactivate_employee(employee)
    load_equipment_service.get_all_equipment_for_employee(employee).each do |equipment|
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

    load_pagination_service.paginate(employees, params[:page])
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end

  def load_pagination_service(service = PaginationService.new)
    @pagination_service ||= service
  end
end