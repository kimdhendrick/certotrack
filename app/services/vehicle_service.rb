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

  def get_all_non_serviced_vehicles_for(service_type)
    serviced_vehicles = service_type.services.map(&:vehicle)
    service_type.customer.vehicles.where.not(id: serviced_vehicles)
  end

  def create_vehicle(current_user, attributes)
    vehicle = Vehicle.new(attributes)
    vehicle.customer_id = current_user.customer_id
    vehicle.save
    vehicle
  end

  def update_vehicle(vehicle, attributes)
    attributes['mileage'] = attributes['mileage'].gsub(/,/, '') if attributes['mileage'].present?
    vehicle.update(attributes)
    vehicle.save
  end

  def delete_vehicle(vehicle)
    vehicle.destroy
  end

  def get_vehicle_makes(current_user, search_term)
    vehicles = get_all_vehicles(current_user)
    vehicles = vehicles.where('make ILIKE :make', {make: "%#{search_term}%"})
    vehicles.map(&:make).uniq
  end

  def get_vehicle_models(current_user, search_term)
    vehicles = get_all_vehicles(current_user)
    vehicles = vehicles.where('vehicle_model ILIKE :model', {model: "%#{search_term}%"})
    vehicles.map(&:vehicle_model).uniq
  end
end