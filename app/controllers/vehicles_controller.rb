class VehiclesController < ApplicationController
  include VehiclesHelper

  before_filter :authenticate_user!,
                :load_vehicle_service,
                :load_location_service

  before_action :_set_vehicle, only: [:show]

  check_authorization

  def index
    authorize! :read, :vehicle

    @vehicles = VehicleListPresenter.new(@vehicle_service.get_all_vehicles(current_user)).present(params)
    @vehicle_count = @vehicles.count
    @report_title = 'All Vehicles'
  end

  def new
    authorize! :create, :vehicle
    @vehicle = Vehicle.new
    _set_locations
  end

  def create
    authorize! :create, :vehicle

    @vehicle = @vehicle_service.create_vehicle(current_user, _vehicle_params)

    if @vehicle.persisted?
      redirect_to @vehicle, notice: 'Vehicle was successfully created.'
    else
      _set_locations
      render action: 'new'
    end
  end

  def show
  end

  def load_vehicle_service(service = VehicleService.new)
    @vehicle_service ||= service
  end

  def load_location_service(service = LocationService.new)
    @location_service ||= service
  end

  private

  def _set_vehicle
    vehicle_pending_authorization = Vehicle.find(params[:id])
    authorize! :manage, vehicle_pending_authorization
    @vehicle = vehicle_pending_authorization
  end

  def _set_locations
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort
  end

  def _vehicle_params
    params.require(:vehicle).permit(vehicle_accessible_parameters)
  end
end