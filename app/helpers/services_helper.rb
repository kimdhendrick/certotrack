module ServicesHelper
  def service_accessible_parameters
    [
      :service_type_id,
      :last_service_date,
      :last_service_mileage,
      :comments
    ]
  end
end