class EmployeeService

  def initialize(params = {})
    @sorter = params[:sorter] || Sorter.new
    @paginator = params[:paginator] || Paginator.new
  end

  def get_all_employees(current_user, params = {})
    employees = _get_employees_for_user(current_user)
    @sorter.sort(employees, params[:sort], params[:direction])
  end

  def get_employee_list(current_user, params = {})
    params[:sort] = 'employee_number' if params[:sort].blank? || params[:sort].nil?
    employees = get_all_employees(current_user, params)
    @paginator.paginate(employees, params[:page])
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

  private

  def _get_employees_for_user(current_user)
    current_user.admin? ? Employee.all : current_user.employees
  end
end