class ServiceTypeService

  def get_all_service_types(current_user)
    current_user.admin? ? ServiceType.all : current_user.service_types
  end
end