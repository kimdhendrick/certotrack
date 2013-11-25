class LocationsController < ApplicationController

  before_filter :authenticate_user!,
                :load_location_service

  check_authorization

  def index
    authorize! :read, :location

    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).present(params)
    @location_count = @locations.count
    @report_title = 'All Locations'
  end

  def load_location_service(service = LocationService.new)
    @location_service ||= service
  end
end