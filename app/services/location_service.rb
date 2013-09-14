class LocationService

  def initialize(params = {})
    @sorter = params[:sorter] || Sorter.new
  end

  def get_all_locations(current_user, params = {})
    locations = _get_locations_for_user(current_user)
    @sorter.sort(locations, params[:sort], params[:direction])
  end

  def _get_locations_for_user(current_user)
    current_user.admin? ? Location.all : current_user.locations
  end
end