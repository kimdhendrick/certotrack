class ServiceTypesController < ModelController
  include ControllerHelper
  include ServiceTypesHelper

  before_filter :load_service_type_service,
                :load_vehicle_service,
                :load_vehicle_servicing_service

  before_action :_set_service_type, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, :vehicle

    @service_types = ServiceTypeListPresenter.new(@service_type_service.get_all_service_types(current_user)).present(params)
    @service_type_count = @service_types.count
    @report_title = 'All Service Types'
  end

  def show
    non_serviced_vehicles_list = @vehicle_service.get_all_non_serviced_vehicles_for(@service_type)
    @non_serviced_vehicles = VehicleListPresenter.new(non_serviced_vehicles_list).sort
    
    service_list = @vehicle_servicing_service.get_all_services_for_service_type(@service_type)
    @services = ServiceListPresenter.new(service_list).sort
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
    status = @service_type_service.delete_service_type(@service_type)

    #if status == :service_exists
    #  redirect_to @service_type, notice: 'This Service Type is assigned to existing Vehicle(s).  You must remove the service from the Vehicles(s) before removing it.'
    #  return
    #end

    redirect_to service_types_path, notice: 'Service Type was successfully deleted.'
  end

  private

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
end