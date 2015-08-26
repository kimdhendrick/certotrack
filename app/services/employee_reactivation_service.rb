class EmployeeReactivationService
  def reactivate_employee(employee)
    deactivated_certifications = Certification.unscoped.where(employee_id: employee.id, active: false)
    deactivated_certifications.each { |certification| certification.update_attribute(:active, true) }

    employee.update_attributes(deactivation_date: nil, active: true)
  end
end