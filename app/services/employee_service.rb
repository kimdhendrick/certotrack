class EmployeeService

  def initialize(params = {})
    @sorter = params[:sorter] || Sorter.new
    @paginator = params[:paginator] || Paginator.new
  end

  def get_all_employees(current_user)
    current_user.admin? ?
      Employee.all.includes(:location) :
      current_user.employees.includes(:location)
  end

  def find(employee_ids, user)
    employees = Employee.find(employee_ids)

    return employees if user.admin?

    employees.select { |employee| employee.customer == user.customer }
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
    employee.destroy
  end

  def get_employees_not_certified_for(certification_type)
    certified_employees = certification_type.certifications.map(&:employee)
    certification_type.customer.employees.where.not(id: certified_employees)
  end
end