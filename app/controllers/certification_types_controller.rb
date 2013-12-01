class CertificationTypesController < ModelController
  include ControllerHelper
  include CertificationTypesHelper

  before_filter :load_certification_type_service,
                :load_employee_service,
                :load_certification_service

  before_action :_set_certification_type, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, :certification

    certification_types_collection = @certification_type_service.get_all_certification_types(current_user)
    @certification_types = CertificationTypeListPresenter.new(certification_types_collection).present(params)
    @certification_types_count = @certification_types.count
  end

  def show
    assign_certifications_by_certification_type(_certified_params(params))
    assign_non_certified_employees_by_certification_type(_noncertified_params(params))
  end

  def edit
    assign_intervals
  end

  def update
    success = @certification_type_service.update_certification_type(@certification_type, _certification_type_params)

    if success
      redirect_to @certification_type, notice: 'Certification Type was successfully updated.'
    else
      assign_intervals
      render action: 'edit'
    end
  end

  def new
    authorize! :create, :certification
    @certification_type = CertificationType.new
    assign_intervals
  end

  def create
    authorize! :create, :certification

    @certification_type = @certification_type_service.create_certification_type(current_user.customer, _certification_type_params)

    if @certification_type.persisted?
      redirect_to @certification_type, notice: 'Certification Type was successfully created.'
    else
      assign_intervals
      render action: 'new'
    end
  end

  def destroy
    status = @certification_type_service.delete_certification_type(@certification_type)

    if status == :certification_exists
      redirect_to @certification_type, notice: 'This Certification Type is assigned to existing Employee(s).  You must uncertify the employee(s) before removing it.'
      return
    end

    redirect_to certification_types_path, notice: 'Certification Type was successfully deleted.'
  end

  def search
    authorize! :read, :certification
    certification_types_collection = @certification_type_service.search_certification_types(current_user, params)
    @certification_types = CertificationTypeListPresenter.new(certification_types_collection).present(params)
    @certification_types_count = @certification_types.count
  end

  def ajax_is_units_based
    authorize! :read, :certification
    results = {is_units_based: CertificationType.find_by_id(params[:certification_type_id]).try(&:units_based?)}
    render json: results
  end

  private

  def _set_certification_type
    @certification_type = _get_model(CertificationType)
  end

  def _certification_type_params
    params.require(:certification_type).permit(certification_type_accessible_parameters)
  end

  def _certified_params(params)
    certified_params = {}
    if (params[:options] == 'certified_employee_name')
      certified_params[:sort] = 'sort_key'
      certified_params[:direction] = params[:direction]
    elsif (params[:options] == 'certified_status')
      certified_params[:sort] = 'status_code'
      certified_params[:direction] = params[:direction]
    end
    certified_params
  end

  def _noncertified_params(params)
    noncertified_params = {}
    if (params[:options] == 'non_certified_employee_name')
      noncertified_params[:sort] = 'sort_key'
      noncertified_params[:direction] = params[:direction]
    end
    noncertified_params
  end
end