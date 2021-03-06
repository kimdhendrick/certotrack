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
    attributes['last_service_mileage'] = attributes['last_service_mileage'].gsub(/,/, '') if attributes['last_service_mileage'].present?
    service.assign_attributes(attributes)
    service.update_expiration_date_and_mileage
    service.save
  end

  def delete_service(service)
    service.destroy
  end

  def reservice(service, attributes)
    service.reservice(attributes)
    service.save
  end

  def count_all_services(user)
    get_all_services(user).count
  end

  def get_all_services(user)
    user.admin? ? Service.all : user.services
  end

  def get_expired_services(user)
    get_all_services(user).select { |service| service.expired? }
  end

  def count_expired_services(user)
    get_expired_services(user).count
  end

  def get_expiring_services(user)
    get_all_services(user).select { |service| service.expiring? }
  end

  def count_expiring_services(user)
    get_expiring_services(user).count
  end
end