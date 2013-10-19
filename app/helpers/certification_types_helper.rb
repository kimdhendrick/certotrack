module CertificationTypesHelper

  def certification_type_presenter_for(certification_type = @certification_type)
    presenter = CertificationTypePresenter.new(certification_type, self)
    yield presenter
  end

  def certification_type_accessible_parameters
    [
      :name,
      :interval,
      :units_required
    ]
  end

  def assign_non_certified_employees_by_certification_type(params = {})
    employees_collection = @employee_service.get_employees_not_certified_for(@certification_type)
    @non_certified_employees = EmployeeListPresenter.new(employees_collection).present(params)
    @non_certified_employee_count = @non_certified_employees.count
  end

  def assign_certifications_by_certification_type(params = {})
    certifications_collection = @certification_service.get_all_certifications_for_certification_type(@certification_type)
    @certifications = CertificationListPresenter.new(certifications_collection).present(params)
    @certifications_count = @certifications.count
  end
end