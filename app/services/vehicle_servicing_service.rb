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
end