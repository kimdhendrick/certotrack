class LocationsController < ApplicationController
  include LocationsHelper

  before_filter :authenticate_user!,
                :load_location_service,
                :load_customer_service

  check_authorization

  def index
    authorize! :read, :location

    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).present(params)
    @location_count = @locations.count
    @report_title = 'All Locations'
  end

  def new
    authorize! :create, :location
    @location = Location.new
    @customers = CustomerListPresenter.new(@customer_service.get_all_customers(current_user)).sort
  end

  def create
    authorize! :create, :location

    @location = @location_service.create_location(current_user, _location_params)

    if @location.persisted?
      redirect_to @location, notice: 'Location was successfully created.'
    else
      @customers = CustomerListPresenter.new(@customer_service.get_all_customers(current_user)).sort
      render action: 'new'
    end
  end

  def show
    _set_location
  end

  def load_location_service(service = LocationService.new)
    @location_service ||= service
  end

  def load_customer_service(service = CustomerService.new)
    @customer_service ||= service
  end

  private

  def _set_location
    location_pending_authorization = Location.find(params[:id])
    authorize! :manage, location_pending_authorization
    @location = location_pending_authorization
  end

  def _location_params
    params.require(:location).permit(location_accessible_parameters)
  end

end