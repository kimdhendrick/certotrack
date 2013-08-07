class LocationService

  def get_all_locations(current_user)
    if (current_user.admin?)
      Location.all
    else
      Location.where(customer: current_user.customer)
    end
  end
end