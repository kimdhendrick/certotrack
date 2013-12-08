class VehiclesController < ModelController
  include ControllerHelper
  include VehiclesHelper

  before_filter :load_vehicle_service,
                :load_location_service

  before_action :_set_vehicle, only: [:show, :edit, :update, :destroy]

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

  def edit
    _set_locations
  end

  def update
    success = @vehicle_service.update_vehicle(@vehicle, _vehicle_params)

    if success
      redirect_to @vehicle, notice: "Vehicle number #{@vehicle.vehicle_number} was successfully updated."
    else
      _set_locations
      render action: 'edit'
    end
  end
  
  def destroy
    vehicle_number = @vehicle.vehicle_number
    @vehicle_service.delete_vehicle(@vehicle)

    redirect_to vehicles_path, notice: "Vehicle number #{vehicle_number} was successfully deleted."
  end

  def search
    authorize! :read, :vehicle

    vehicles = @vehicle_service.search_vehicles(current_user, params)
    @vehicles = VehicleListPresenter.new(vehicles).present(params)
    @vehicle_count = @vehicles.count
    @report_title = "Search Vehicles"
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort
  end

  def ajax_vehicle_make
    authorize! :read, :vehicle
    render json: @vehicle_service.get_vehicle_makes(current_user, params[:term])
  end

  def ajax_vehicle_model
    authorize! :read, :vehicle
    render json: @vehicle_service.get_vehicle_models(current_user, params[:term])
  end

  private

  def _set_vehicle
    @vehicle = _get_model(Vehicle)
  end

  def _set_locations
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort
  end

  def _vehicle_params
    params.require(:vehicle).permit(vehicle_accessible_parameters)
  end
end