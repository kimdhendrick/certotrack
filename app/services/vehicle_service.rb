class VehicleService

  def get_all_vehicles(current_user)
    current_user.admin? ? Vehicle.all : current_user.vehicles
  end
end