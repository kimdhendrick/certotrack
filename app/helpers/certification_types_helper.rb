module CertificationTypesHelper

  def certification_type_accessible_parameters
    [
      :name,
      :interval,
      :units_required
    ]
  end
end