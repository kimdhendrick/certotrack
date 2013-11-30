class VehiclesController < ApplicationController

  before_filter :authenticate_user!,
                :load_vehicle_service

  check_authorization

  def index
    authorize! :read, :vehicle

    @vehicles = VehicleListPresenter.new(@vehicle_service.get_all_vehicles(current_user)).present(params)
    @vehicle_count = @vehicles.count
    @report_title = 'All Vehicles'
  end

  def load_vehicle_service(service = VehicleService.new)
    @vehicle_service ||= service
  end
end