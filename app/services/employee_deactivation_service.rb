class EmployeeDeactivationService

  def initialize(params = {})
    @paginator = params[:paginator] || Paginator.new
  end

  def deactivate_employee(employee)
    employee.equipments.each { |equipment| equipment.employee = nil }
    employee.certifications.each { |certification| certification.active = false }
    employee.deactivation_date = Date.today
    employee.active = false
    employee.save
  end

  def get_deactivated_employees(current_user, params = {})
    all_employees = Employee.unscoped.where(active: false)

    employees =
      current_user.admin? ?
        all_employees :
        all_employees.where(customer: current_user.customer)

    @paginator.paginate(employees, params[:page])
  end
end