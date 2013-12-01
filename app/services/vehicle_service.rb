class VehicleService

  def get_all_vehicles(current_user)
    current_user.admin? ? Vehicle.all : current_user.vehicles
  end

  def create_vehicle(current_user, attributes)
    vehicle = Vehicle.new(attributes)
    vehicle.customer_id = current_user.customer_id
    vehicle.save
    vehicle
  end

  def update_vehicle(vehicle, attributes)
    vehicle.update(attributes)
    if attributes['mileage']
      vehicle.mileage = attributes['mileage'].gsub(/[^\d\.]/, '')
    end
    vehicle.save
  end

  def delete_vehicle(vehicle)
    vehicle.destroy
  end
end