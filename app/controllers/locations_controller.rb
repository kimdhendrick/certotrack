class LocationsController < ModelController
  include ControllerHelper
  include LocationsHelper

  before_filter :load_location_service,
                :load_customer_service

  before_action :_set_location, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, :location

    @report_title = 'All Locations'
    location_collection = @location_service.get_all_locations(current_user)
    @locations = LocationListPresenter.new(location_collection).present(params)
    @location_count = location_collection.count
  end

  def new
    authorize! :create, :location
    @location = Location.new(customer_id: params[:customer_id])
    _set_customers
  end

  def create
    authorize! :create, :location

    @location = @location_service.create_location(current_user, _location_params_for_create)

    if @location.persisted?
      flash[:success] = _success_message(@location.name, 'created')
      redirect_to @location
    else
      _set_customers
      render action: 'new'
    end
  end

  def edit
    _set_customers
  end

  def update
    success = @location_service.update_location(current_user, @location, _location_params)

    if success
      flash[:success] = _success_message(@location.name, 'updated')
      redirect_to @location
    else
      _set_customers
      render action: 'edit'
    end
  end

  def show
  end

  def destroy
    location_name = @location.name

    if @location_service.delete_location(@location)
      flash[:success] = _success_message(location_name, 'deleted')
      redirect_to locations_path
    else
      render :show
    end
  end

  private

  def _success_message(location_name, verb)
    "Location '#{location_name}' was successfully #{verb}."
  end

  def _set_customers
    @customers = CustomerListPresenter.new(@customer_service.get_all_customers(current_user)).sort
  end

  def _set_location
    @location = _get_model(Location)
  end

  def _location_params_for_create
    merge_created_by(_location_params)
  end

  def _location_params
    params.require(:location).permit(location_accessible_parameters)
  end
end