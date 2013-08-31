class EmployeesService

  def get_all_employees(current_user, params = {})
    employees = current_user.admin? ? Employee.all : Employee.where(customer: current_user.customer)
    employees = load_sort_service.sort(employees, params[:sort], params[:direction], 'employee_number')
    load_pagination_service.paginate(employees, params[:page])
  end

  def create_employee(customer, attributes)
    @employee = Employee.new(attributes)
    @employee.customer = customer
    @employee.save
    @employee
  end

  def update_employee(employee, attributes)
    employee.update_attributes(attributes)
    employee.save
  end

  def delete_employee(employee)
    if Equipment.where(employee: employee).any?
      return :equipment_exists
    end

    employee.destroy
  end

  def deactivate_employee(employee)
    load_equipment_service.get_all_equipment_for_employee(employee).each do |equipment|
      equipment.employee = nil
      equipment.save
    end

    employee.deactivation_date = Date.today
    employee.active = false
    employee.save
  end

  def load_sort_service(service = SortService.new)
    @sort_service ||= service
  end

  def load_pagination_service(service = PaginationService.new)
    @pagination_service ||= service
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end
end