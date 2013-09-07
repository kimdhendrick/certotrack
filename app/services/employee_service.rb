class EmployeeService

  def get_all_employees(current_user)
    current_user.admin? ? Employee.all : current_user.employees
  end

  def get_employee_list(current_user, params = {})
    employees = get_all_employees(current_user)
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
    if employee.equipments.any?
      return :equipment_exists
    end

    employee.destroy
  end

  def load_sort_service(service = SortService.new)
    @sort_service ||= service
  end

  def load_pagination_service(service = PaginationService.new)
    @pagination_service ||= service
  end
end