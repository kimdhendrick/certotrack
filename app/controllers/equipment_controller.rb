class EquipmentController < ModelController
  include ControllerHelper
  include EquipmentHelper

  before_filter :load_equipment_service,
                :load_location_service,
                :load_employee_service

  before_action :_set_equipment, only: [:show, :edit, :update, :destroy]

  def index
    _render_equipment_list(:all, 'All Equipment')
  end

  def expired
    _render_equipment_list(:expired, 'Expired Equipment List')
  end

  def expiring
    _render_equipment_list(:expiring, 'Expiring Equipment List')
  end

  def noninspectable
    _render_equipment_list(:noninspectable, 'Non-Inspectable Equipment List')
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

    @equipment = @equipment_service.create_equipment(current_user.customer, _equipment_params_for_create)

    if @equipment.persisted?
      flash[:success] = _success_message(@equipment.name, 'created')
      redirect_to @equipment
    else
      assign_intervals
      render action: 'new'
    end
  end

  def update
    success = @equipment_service.update_equipment(@equipment, _equipment_params)

    if success
      flash[:success] = _success_message(@equipment.name, 'updated')
      redirect_to @equipment
    else
      assign_intervals
      render action: 'edit'
    end
  end

  def destroy
    equipment_name = @equipment.name
    @equipment_service.delete_equipment(@equipment)
    flash[:success] = _success_message(equipment_name, 'deleted')
    redirect_to equipment_index_url
  end

  def search
    authorize! :read, :equipment

    equipment_collection = @equipment_service.search_equipment(current_user, params)

    _render_search('Search Equipment', equipment_collection)
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

  private

  def _success_message(equipment_name, verb)
    "Equipment '#{equipment_name}' was successfully #{verb}."
  end

  def _render_equipment_list(equipment_type, report_title)
    authorize! :read, :equipment

    equipment_collection = @equipment_service.public_send("get_#{equipment_type}_equipment", current_user)

    @export_template = "#{equipment_type.to_s}_equipment_export"

    respond_to do |format|
      format.html { _render_equipment_list_as_html(report_title, equipment_collection) }
      format.csv { _render_collection_as_csv(equipment_type, equipment_collection) }
      format.xls { _render_collection_as_xls(report_title, equipment_type, equipment_collection) }
      format.pdf { _render_collection_as_pdf(report_title, equipment_type, equipment_collection) }
    end
  end

  def _render_equipment_list_as_html(report_title, equipment_collection)
    @report_title = report_title
    @equipments = EquipmentListPresenter.new(equipment_collection).present(params)
    @equipment_count = equipment_collection.count
    render 'equipment/index'
  end

  def _filename(equipment_type, extension)
    equipment_type == :all ? "equipment.#{extension}" : "#{equipment_type}_equipment.#{extension}"
  end

  def _render_search_collection_as_html(equipment_collection)
    @report_title = 'Search Equipment'
    @equipments = EquipmentListPresenter.new(equipment_collection).present(params)
    @equipment_count = equipment_collection.count
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort

    employees_collection = @employee_service.get_all_employees(current_user)
    @employees = EmployeeListPresenter.new(employees_collection).present({sort: :sort_key})
  end

  def _set_equipment
    @equipment = _get_model(Equipment)
  end

  def _equipment_params_for_create
    merge_created_by(_equipment_params)
  end

  def _equipment_params
    params.require(:equipment).
      permit(equipment_accessible_parameters)
  end
end