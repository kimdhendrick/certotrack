class EmployeesService

  def get_all_employees(current_user)
    if (current_user.admin?)
      Employee.all
    else
      Employee.where(customer: current_user.customer)
    end
  end

  def create_employee(customer, attributes)
    @employee = Employee.new(attributes)
    @employee.customer = customer
    @employee.save
    @employee
  end
end