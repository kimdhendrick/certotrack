class ReservicesController < ModelController
  before_action :load_vehicle_servicing_service
  before_action :_set_service, only: [:new, :create]

  def new; end

  def create
    if (@vehicle_servicing_service.reservice(@service, reservice_attributes))
      redirect_to @service
    else
      render action: :new
    end
  end

  def load_vehicle_servicing_service(vehicle_servicing_service = VehicleServicingService.new)
    @vehicle_servicing_service ||= vehicle_servicing_service
  end

  private

  def _set_service
    service_pending_authorization = Service.find(params[:service_id])
    authorize! :manage, service_pending_authorization
    @service = service_pending_authorization
  end

  def reservice_attributes
    params.permit(:start_date, :start_mileage, :comments)
  end
end
