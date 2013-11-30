module VehiclesHelper

  def vehicle_accessible_parameters
    [
      :vehicle_number,
      :vin,
      :license_plate,
      :make,
      :vehicle_model,
      :year,
      :mileage,
      :location_id
    ]
  end
end