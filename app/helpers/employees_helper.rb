module EmployeesHelper
  def employees_accessible_parameters
    [
      :first_name,
      :last_name,
      :employee_number,
      :location_id
    ]
  end

  def assign_certifications_by_employee(params = {})
    certifications_for_employee = @certification_service.get_all_certifications_for_employee(@employee)
    @certifications = CertificationListPresenter.new(certifications_for_employee).present(params)
  end
end