module CertificationTypesHelper

  def certification_type_accessible_parameters
    [
      :name,
      :inspection_interval,
      :units_required
    ]
  end
end