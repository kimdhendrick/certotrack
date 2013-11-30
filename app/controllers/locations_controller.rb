class LocationsController < ApplicationController
  include PresentableModelHelper
  include LocationsHelper

  before_filter :authenticate_user!,
                :load_location_service,
                :load_customer_service

  before_action :_set_location, only: [:show, :edit, :update, :destroy]

  check_authorization

  def index
    authorize! :read, :location

    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).present(params)
    @location_count = @locations.count
    @report_title = 'All Locations'
  end

  def new
    authorize! :create, :location
    @location = Location.new
    _set_customers
  end

  def create
    authorize! :create, :location

    @location = @location_service.create_location(current_user, _location_params)

    if @location.persisted?
      redirect_to @location, notice: 'Location was successfully created.'
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
      redirect_to @location, notice: 'Location was successfully updated.'
    else
      _set_customers
      render action: 'edit'
    end
  end

  def show
  end

  def destroy
    location_name = @location.name
    status = @location_service.delete_location(@location)

    if status == :equipment_exists
      redirect_to @location, notice: 'Location has equipment assigned, you must reassign them before deleting the location.'
      return
    end

    if status == :employee_exists
      redirect_to @location, notice: 'Location has employees assigned, you must reassign them before deleting the location.'
      return
    end

    redirect_to locations_path, notice: "Location #{location_name} was successfully deleted."
  end

  def load_location_service(service = LocationService.new)
    @location_service ||= service
  end

  def load_customer_service(service = CustomerService.new)
    @customer_service ||= service
  end

  private

  def _set_customers
    @customers = CustomerListPresenter.new(@customer_service.get_all_customers(current_user)).sort
  end

  def _set_location
    location_pending_authorization = Location.find(params[:id])
    authorize! :manage, location_pending_authorization
    @location = location_pending_authorization
    @model = location_pending_authorization
  end

  def _location_params
    params.require(:location).permit(location_accessible_parameters)
  end

end