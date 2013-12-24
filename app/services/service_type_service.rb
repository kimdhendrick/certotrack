class ServiceTypeService

  def get_all_service_types(current_user)
    current_user.admin? ? ServiceType.all : current_user.service_types
  end

  def create_service_type(customer, attributes)
    service_type = ServiceType.new(attributes)
    service_type.customer = customer
    service_type.save
    service_type
  end

  def update_service_type(service_type, attributes)
    service_type.update(attributes)
    service_type.save
  end
end