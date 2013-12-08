class VehicleService

  def initialize(params = {})
    @search_service = params[:search_service] || SearchService.new
  end

  def search_vehicles(current_user, attributes)
    @search_service.search(get_all_vehicles(current_user), attributes)
  end

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

  def get_vehicle_makes(current_user, search_term)
    vehicles = get_all_vehicles(current_user)
    vehicles = vehicles.where("make ILIKE :make", {make: "%#{search_term}%"})
    vehicles.map(&:make).uniq
  end

  def get_vehicle_models(current_user, search_term)
    vehicles = get_all_vehicles(current_user)
    vehicles = vehicles.where("vehicle_model ILIKE :model", {model: "%#{search_term}%"})
    vehicles.map(&:vehicle_model).uniq
  end
end