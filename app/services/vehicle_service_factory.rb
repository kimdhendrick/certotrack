class VehicleServiceFactory

  def initialize(params = {})
    @expiration_calculator = params[:expiration_calculator] || ExpirationCalculator.new
  end

  def new_instance(attributes)
    vehicle_id = attributes[:vehicle_id]
    service_type_id = attributes[:service_type_id]
    customer = User.find(attributes[:current_user_id]).customer

    service = Service.new(vehicle_id: vehicle_id, service_type_id: service_type_id, customer: customer)
    service = _build_active_service_period(service, attributes)
    service.expiration_date = _expires_on_date(service_type_id, service.last_service_date)
    service.expiration_mileage = _expires_on_mileage(service_type_id, service.last_service_mileage)
    service
  end

  private

  def _build_active_service_period(service, attributes)
    service_period_params =
      {
        service: service,
        start_date: attributes[:service_date],
        start_mileage: attributes[:service_mileage],
        comments: attributes[:comments]
      }

    active_service_period = service.create_active_service_period(service_period_params)

    if active_service_period.valid?
      service.service_periods << active_service_period
    end

    service
  end

  def _expires_on_date(service_type_id, service_date)
    return nil if service_date.blank? || service_type_id.blank?
    service_type = ServiceType.find(service_type_id)
    interval = Interval.find_by_text(service_type.interval_date)
    interval.from(service_date) if interval.present?
  end

  def _expires_on_mileage(service_type_id, service_mileage)
    return nil if service_mileage.blank? || service_type_id.blank?
    service_type = ServiceType.find(service_type_id)
    @expiration_calculator.calculate_mileage(service_mileage, service_type.interval_mileage)
  end
end