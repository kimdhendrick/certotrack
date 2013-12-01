module CertificationTypesHelper
  include PresentableModelHelper

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

  CertificationTypeType = Struct.new(:id, :name)

  def get_certification_type_types
    @certification_types = [
      CertificationTypeType.new('units_based', 'Units Based'),
      CertificationTypeType.new('date_based', 'Date Based')
    ]
  end

end