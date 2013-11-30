class EquipmentController < ApplicationController
  include ControllerHelper
  include EquipmentHelper
  include PresentableModelHelper

  before_filter :authenticate_user!,
                :load_equipment_service,
                :load_location_service,
                :load_employee_service

  before_action :_set_equipment, only: [:show, :edit, :update, :destroy]

  check_authorization

  def index
    authorize! :read, :equipment

    @report_title = 'All Equipment'
    equipment_collection = @equipment_service.get_all_equipment(current_user)
    @equipments = EquipmentListPresenter.new(equipment_collection).present(params)
    @equipment_count = @equipments.count
  end

  def expired
    authorize! :read, :equipment

    @report_title = 'Expired Equipment List'
    equipment_collection = @equipment_service.get_expired_equipment(current_user)
    @equipments = EquipmentListPresenter.new(equipment_collection).present(params)
    @equipment_count = @equipments.count
    render 'equipment/index'
  end

  def expiring
    authorize! :read, :equipment

    @report_title = 'Expiring Equipment List'
    equipment_collection = @equipment_service.get_expiring_equipment(current_user)
    @equipments = EquipmentListPresenter.new(equipment_collection).present(params)
    @equipment_count = @equipments.count
    render 'equipment/index'
  end

  def noninspectable
    authorize! :read, :equipment

    @report_title = 'Non-Inspectable Equipment List'
    equipment_collection = @equipment_service.get_noninspectable_equipment(current_user)
    @equipments = EquipmentListPresenter.new(equipment_collection).present(params)
    @equipment_count = @equipments.count
    render 'equipment/index'
  end

  def show
  end

  def new
    authorize! :create, :equipment
    assign_intervals
    @equipment = Equipment.new
  end

  def edit
    assign_intervals
  end

  def create
    authorize! :create, :equipment

    @equipment = @equipment_service.create_equipment(current_user.customer, _equipment_params)

    if @equipment.persisted?
      redirect_to @equipment, notice: 'Equipment was successfully created.'
    else
      assign_intervals
      render action: 'new'
    end
  end

  def update
    success = @equipment_service.update_equipment(@equipment, _equipment_params)

    if success
      redirect_to @equipment, notice: 'Equipment was successfully updated.'
    else
      assign_intervals
      render action: 'edit'
    end
  end

  def destroy
    @equipment_service.delete_equipment(@equipment)
    redirect_to equipment_index_url, notice: 'Equipment was successfully deleted.'
  end

  def search
    authorize! :read, :equipment

    @report_title = 'Search Equipment'
    equipment_collection = @equipment_service.search_equipment(current_user, params)
    @equipments = EquipmentListPresenter.new(equipment_collection).present(params)
    @equipment_count = @equipments.count
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort

    employees_collection = @employee_service.get_all_employees(current_user)
    @employees = EmployeeListPresenter.new(employees_collection).present({sort: :sort_key})
  end

  def ajax_assignee
    authorize! :read, :equipment

    if params[:assignee] == 'Location'
      locations = @location_service.get_all_locations(current_user)
      locations = LocationListPresenter.new(locations).sort
      render json: locations.map { |l| [l.id, l.name] }
    else
      employees = @employee_service.get_all_employees(current_user)
      employees = EmployeeListPresenter.new(employees).sort({sort: 'sort_key', direction: 'asc'})
      render json: employees.map { |employee| [employee.id, employee.name] }
    end
  end

  def ajax_equipment_name
    authorize! :read, :equipment
    render json: @equipment_service.get_equipment_names(current_user, params[:term])
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end

  def load_employee_service(service = EmployeeService.new)
    @employee_service ||= service
  end

  def load_location_service(service = LocationService.new)
    @location_service ||= service
  end

  private

  def _set_equipment
    equipment_pending_authorization = Equipment.find(params[:id])
    authorize! :manage, equipment_pending_authorization
    @equipment = equipment_pending_authorization
    @model = equipment_pending_authorization
  end

  def _equipment_params
    params.require(:equipment).permit(equipment_accessible_parameters)
  end
end
