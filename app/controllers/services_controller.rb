class ServicesController < ModelController
  include ControllerHelper

  before_filter :load_vehicle_servicing_service,
                :load_service_type_service,
                :load_vehicle_service

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

  private

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