module ControllerHelper
  def assign_intervals
    @intervals = Interval.all.to_a
  end

  def load_vehicle_service(service = VehicleService.new)
    @vehicle_service ||= service
  end

  def load_location_service(service = LocationService.new)
    @location_service ||= service
  end

  def load_customer_service(service = CustomerService.new)
    @customer_service ||= service
  end

  def load_user_service(service = UserService.new)
    @user_service ||= service
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end

  def load_employee_service(service = EmployeeService.new)
    @employee_service ||= service
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end

  def load_certification_type_service(service = CertificationTypeService.new)
    @certification_type_service ||= service
  end

  def load_service_type_service(service = ServiceTypeService.new)
    @service_type_service ||= service
  end

  def load_vehicle_servicing_service(service = VehicleServicingService.new)
    @vehicle_servicing_service ||= service
  end

  private

  def _get_model(model_class, param_name = :id)
    model_pending_authorization = model_class.find(params[param_name])
    resource = model_class.name.underscore.to_sym

    if can? :manage, resource
      authorize! :manage, resource
    else
      authorize! :manage, model_pending_authorization
    end

    model_pending_authorization
  end
end