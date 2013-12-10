class ServiceTypesController < ModelController
  include ControllerHelper

  before_filter :load_service_type_service

  def index
    authorize! :read, :vehicle

    @service_types = ServiceTypeListPresenter.new(@service_type_service.get_all_service_types(current_user)).present(params)
    @service_type_count = @service_types.count
    @report_title = 'All Service Types'
  end
end