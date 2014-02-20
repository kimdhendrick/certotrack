class LocationService

  def get_all_locations(current_user)
    current_user.admin? ? Location.all : current_user.locations
  end

  def create_location(current_user, attributes)
    location = Location.new(attributes)
    unless current_user.admin?
      location.customer_id = current_user.customer_id
    end
    location.save
    location
  end

  def update_location(current_user, location, attributes)
    location.update(attributes)
    unless current_user.admin?
      location.customer_id = current_user.customer_id
    end
    location.save
  end

  def delete_location(location)
    location.destroy
  end
end