class ServiceTypesController < ModelController
  include ControllerHelper
  include ServiceTypesHelper

  before_filter :load_service_type_service,
                :load_vehicle_service,
                :load_vehicle_servicing_service

  before_action :_set_service_type, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, :vehicle

    @report_title = 'All Service Types'
    service_type_collection = @service_type_service.get_all_service_types(current_user)
    @service_types = ServiceTypeListPresenter.new(service_type_collection).present(params)
    @service_type_count = service_type_collection.count
  end

  def show
    _set_non_serviced_vehicles
    _set_serviced_vehicles
  end

  def new
    authorize! :create, :service_type
    @service_type = ServiceType.new
    _assign_interval_dates
    _assign_interval_mileages
    _assign_expiration_types
  end

  def create
    authorize! :create, :service_type

    @service_type = @service_type_service.create_service_type(current_user.customer, _service_type_params)

    if @service_type.persisted?
      redirect_to @service_type, notice: 'Service Type was successfully created.'
    else
      _assign_interval_dates
      _assign_interval_mileages
      _assign_expiration_types
      render action: 'new'
    end
  end

  def edit
    _assign_interval_dates
    _assign_interval_mileages
    _assign_expiration_types
  end

  def update
    success = @service_type_service.update_service_type(@service_type, _service_type_params)

    if success
      redirect_to @service_type, notice: 'Service Type was successfully updated.'
    else
      _assign_interval_dates
      _assign_interval_mileages
      _assign_expiration_types
      render action: 'edit'
    end
  end

  def destroy
    if @service_type_service.delete_service_type(@service_type)
      redirect_to service_types_path, notice: 'Service Type was successfully deleted.'
    else
      _set_non_serviced_vehicles
      _set_serviced_vehicles
      render :show
    end
  end

  private

  def _set_serviced_vehicles
    service_list = @vehicle_servicing_service.get_all_services_for_service_type(@service_type)
    @services = ServiceListPresenter.new(service_list).sort(_serviced_params)
  end

  def _set_non_serviced_vehicles
    non_serviced_vehicles_list = @vehicle_service.get_all_non_serviced_vehicles_for(@service_type)
    @non_serviced_vehicles = VehicleListPresenter.new(non_serviced_vehicles_list).sort(_unserviced_params)
  end

  def _set_service_type
    @service_type = _get_model(ServiceType)
  end

  def _assign_interval_dates
    @interval_dates = Interval.all.to_a - [Interval::NOT_REQUIRED]
  end

  def _assign_interval_mileages
    @interval_mileages = ServiceType::INTERVAL_MILEAGES
  end

  def _assign_expiration_types
    @expiration_types = ServiceType::EXPIRATION_TYPES
  end

  def _service_type_params
    params.require(:service_type).permit(service_type_accessible_parameters)
  end

  def _serviced_params
    serviced_params = {}
    if (params[:options] == 'serviced_vehicles')
      serviced_params[:sort] = params[:sort]
      serviced_params[:direction] = params[:direction]
    end
    serviced_params
  end

  def _unserviced_params
    unserviced_params = {}
    if (params[:options] == 'unserviced_vehicles')
      unserviced_params[:sort] = params[:sort]
      unserviced_params[:direction] = params[:direction]
    end
    unserviced_params
  end
end