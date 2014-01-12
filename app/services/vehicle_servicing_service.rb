class VehicleServicingService

  def initialize(params = {})
    @vehicle_service_factory ||= params[:vehicle_service_factory] || VehicleServiceFactory.new
  end

  def new_vehicle_service(current_user, vehicle_id, service_type_id)
    @vehicle_service_factory.new_instance(
      current_user_id: current_user.id,
      vehicle_id: vehicle_id,
      service_type_id: service_type_id
    )
  end

  def service_vehicle(current_user, vehicle_id, service_type_id, service_date, service_mileage, comments)
    service = @vehicle_service_factory.new_instance(
      current_user_id: current_user.id,
      vehicle_id: vehicle_id,
      service_type_id: service_type_id,
      service_date: service_date,
      service_mileage: service_mileage,
      comments: comments
    )
    service.save
    service
  end

  def get_all_services_for_vehicle(vehicle)
    vehicle.services
  end

  def get_all_services_for_service_type(service_type)
    service_type.services
  end

  def update_service(service, attributes)
    service.update(attributes)
    if attributes['last_service_mileage']
      service.last_service_mileage = attributes['last_service_mileage'].gsub(/[^\d\.]/, '')
    end
    ExpirationUpdater.update_expiration_date_and_mileage(service)
  end

  def delete_service(service)
    service.destroy
  end
end