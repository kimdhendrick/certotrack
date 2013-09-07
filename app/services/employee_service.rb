class EmployeeService

  def initialize(params = {})
    @sort_service = params[:sort_service] || SortService.new
    @pagination_service = params[:pagination_service] || PaginationService.new
  end

  def get_all_employees(current_user)
    current_user.admin? ? Employee.all : current_user.employees
  end

  def get_employee_list(current_user, params = {})
    employees = get_all_employees(current_user)
    employees = @sort_service.sort(employees, params[:sort], params[:direction], 'employee_number')
    @pagination_service.paginate(employees, params[:page])
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
end