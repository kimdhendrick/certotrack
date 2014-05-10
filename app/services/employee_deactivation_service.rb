class EmployeeDeactivationService
  def deactivate_employee(employee)
    employee.equipments.each { |equipment| equipment.employee = nil }
    employee.certifications.each { |certification| certification.active = false }
    employee.deactivation_date = Date.current
    employee.active = false
    employee.save(validate: false)
  end

  def get_deactivated_employees(current_user)
    all_employees = Employee.unscoped.where(active: false).includes(:location)

    current_user.admin? ?
      all_employees :
      all_employees.where(customer: current_user.customer)
  end
end