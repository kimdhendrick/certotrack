class ServiceTypesController < ModelController
  include ControllerHelper

  before_filter :load_service_type_service,
                :load_vehicle_service

  before_action :_set_service_type, only: [:show]

  def index
    authorize! :read, :vehicle

    @service_types = ServiceTypeListPresenter.new(@service_type_service.get_all_service_types(current_user)).present(params)
    @service_type_count = @service_types.count
    @report_title = 'All Service Types'
  end

  def show
    non_serviced_vehicles_list = @vehicle_service.get_all_non_serviced_vehicles_for(@service_type, current_user)
    @non_serviced_vehicles = VehicleListPresenter.new(non_serviced_vehicles_list).sort
  end

  private

  def _set_service_type
    @service_type = _get_model(ServiceType)
  end

end