module VehiclesHelper
  include PresentableModelHelper
  
  def vehicle_accessible_parameters
    [
      :vehicle_number,
      :vin,
      :license_plate,
      :make,
      :vehicle_model,
      :year,
      :mileage,
      :tire_size,
      :location_id
    ]
  end
end