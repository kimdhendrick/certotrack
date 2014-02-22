class ServicesController < ModelController
  include ControllerHelper

  before_filter :load_vehicle_servicing_service,
                :load_service_type_service,
                :load_vehicle_service

  before_action :_set_service, only: [:show, :edit, :update, :destroy, :service_history]

  def index
    authorize! :read, :vehicle

    @report_title = 'All Vehicle Services'

    _render_services(@vehicle_servicing_service.get_all_services(current_user))
  end

  def expired
    authorize! :read, :vehicle

    @report_title = 'Expired Vehicle Services'

    _render_services(@vehicle_servicing_service.get_expired_services(current_user))
  end

  def new
    authorize! :create, :service

    @source = params[:source]
    _set_service_types(current_user)
    _set_new_service(current_user, params[:vehicle_id], params[:service_type_id])
    _set_vehicles(current_user)
  end

  def create
    authorize! :create, :service

    @service = @vehicle_servicing_service.service_vehicle(
      current_user,
      params[:service][:vehicle_id],
      params[:service][:service_type_id],
      params[:service][:last_service_date],
      params[:service][:last_service_mileage],
      params[:service][:comments]
    )

    if !@service.valid?
      return _render_new
    elsif _redirect_to_vehicle?
      redirect_to @service.vehicle, notice: _success_message(@service)
    elsif _redirect_to_service_type?
      redirect_to @service.service_type, notice: _success_message(@service)
    else
      return _render_new_with_message _success_message(@service)
    end
  end

  def show
  end

  def edit
    authorize! :create, :service
    _set_service_types(current_user)
  end

  def update
    success = @vehicle_servicing_service.update_service(@service, _service_params)

    if success
      redirect_to @service.service_type, notice: 'Service was successfully updated.'
    else
      _set_service_types(current_user)
      render action: 'edit'
    end
  end

  def destroy
    service_type = @service.service_type
    vehicle = @service.vehicle
    @vehicle_servicing_service.delete_service(@service)
    redirect_to service_type, notice: "Service #{service_type.name} for Vehicle #{VehiclePresenter.new(vehicle).name} deleted."
  end

  def service_history
    @service_periods = ServicePeriodListPresenter.new(@service.service_periods).present
  end

  private

  def _render_services(services_collection)
    @services = ServiceListPresenter.new(services_collection).present(params)
    @service_count = services_collection.count
    render 'services/index'
  end

  def _service_params
    service_accessible_parameters = [
      :service_type_id,
      :last_service_date,
      :last_service_mileage,
      :comments
    ]

    params.require(:service).permit(service_accessible_parameters)
  end

  def _set_service
    @service = _get_model(Service)
  end

  def _set_service_types(current_user)
    service_types = @service_type_service.get_all_service_types(current_user)
    @service_types = ServiceTypeListPresenter.new(service_types).sort
  end

  def _set_vehicles(current_user)
    vehicles = @vehicle_service.get_all_vehicles(current_user)
    @vehicles = VehicleListPresenter.new(vehicles).sort
  end

  def _success_message(service)
    "Service: #{service.name} created for Vehicle #{VehiclePresenter.new(service.vehicle).name}."
  end

  def _set_new_service(current_user, vehicle_id, service_type_id)
    @service = @vehicle_servicing_service.new_vehicle_service(current_user, vehicle_id, service_type_id)
  end

  def _redirect_to_vehicle?
    params[:commit] == 'Create' && params[:source] == 'vehicle'
  end

  def _redirect_to_service_type?
    params[:commit] == 'Create' &&
      (params[:source] == 'service_type' || params[:source] == 'service')
  end

  def _render_new_with_message(message = nil)
    flash[:notice] = message
    _set_new_service(current_user, params[:service][:vehicle_id], nil)
    _render_new
  end

  def _render_new
    @source = params[:source]
    _set_service_types(current_user)
    _set_vehicles(current_user)
    render action: 'new'
    nil
  end
end