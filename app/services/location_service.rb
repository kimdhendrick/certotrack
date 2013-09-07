class LocationService

  def get_all_locations(current_user)
    current_user.admin? ?
      Location.all :
      current_user.locations
  end
end