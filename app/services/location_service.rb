class LocationService

  def get_all_locations(current_user)
    current_user.admin? ? Location.all : current_user.locations
  end

  def create_location(current_user, attributes)
    location = Location.new(attributes)
    _set_customer(current_user, location)
    location.save
    location
  end

  def update_location(current_user, location, attributes)
    location.update(attributes)
    _set_customer(current_user, location)
    location.save
  end

  def delete_location(location)
    location.destroy
  end

  private

  def _set_customer(current_user, location)
    return if current_user.admin?

    location.customer_id = current_user.customer_id
  end
end