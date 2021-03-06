class VehiclesController < ModelController
  include ControllerHelper
  include VehiclesHelper

  before_filter :load_vehicle_service,
                :load_location_service,
                :load_vehicle_servicing_service

  before_action :_set_vehicle, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, :vehicle

    @report_title = 'All Vehicles'
    vehicle_collection = @vehicle_service.get_all_vehicles(current_user)
    @vehicles = VehicleListPresenter.new(vehicle_collection).present(params)
    @vehicle_count = vehicle_collection.count
  end

  def new
    authorize! :create, :vehicle
    @vehicle = Vehicle.new
    _set_locations
  end

  def create
    authorize! :create, :vehicle

    @vehicle = @vehicle_service.create_vehicle(current_user, _vehicle_params_for_create)

    if @vehicle.persisted?
      flash[:success] = _success_message(@vehicle.vehicle_number, 'created')
      redirect_to @vehicle
    else
      _set_locations
      render action: 'new'
    end
  end

  def show
    _set_services
  end

  def _set_services
    vehicle_services = @vehicle_servicing_service.get_all_services_for_vehicle(@vehicle)
    @services = ServiceListPresenter.new(vehicle_services).sort(params)
  end

  def edit
    _set_locations
  end

  def update
    success = @vehicle_service.update_vehicle(@vehicle, _vehicle_params)

    if success
      flash[:success] = _success_message(@vehicle.vehicle_number, 'updated')
      redirect_to @vehicle
    else
      _set_locations
      render action: 'edit'
    end
  end
  
  def destroy
    vehicle_number = @vehicle.vehicle_number

    if @vehicle_service.delete_vehicle(@vehicle)
      flash[:success] = _success_message(vehicle_number, 'deleted')
      redirect_to vehicles_path
    else
      _set_services
      render :show
    end
  end

  def search
    authorize! :read, :vehicle

    @report_title = 'Search Vehicles'
    vehicle_collection = @vehicle_service.search_vehicles(current_user, params)
    @vehicles = VehicleListPresenter.new(vehicle_collection).present(params)
    @vehicle_count = vehicle_collection.count
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

  def _success_message(vehicle_number, verb)
    "Vehicle number '#{vehicle_number}' was successfully #{verb}."
  end

  def _set_vehicle
    @vehicle = _get_model(Vehicle)
  end

  def _set_locations
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort
  end

  def _vehicle_params_for_create
    merge_created_by(_vehicle_params)
  end

  def _vehicle_params
    params.require(:vehicle).permit(vehicle_accessible_parameters)
  end
end