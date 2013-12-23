module ServiceTypesHelper

  def service_type_accessible_parameters
    [
      :name,
      :expiration_type,
      :interval_date,
      :interval_mileage
    ]
  end
end