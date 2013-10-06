class CertificationTypesController < ApplicationController
  include ControllerHelper
  include CertificationTypesHelper

  before_filter :authenticate_user!,
                :load_certification_type_service,
                :load_employee_service,
                :load_certification_service

  before_action :_set_certification_type, only: [:show, :edit, :update, :destroy]

  check_authorization

  def index
    authorize! :read, :certification

    certification_types_collection = @certification_type_service.get_all_certification_types(current_user)
    @certification_types = CertificationTypeListPresenter.new(certification_types_collection).present(params)
    @certification_types_count = @certification_types.count
  end

  def show
    certifications_collection = @certification_service.get_all_certifications_for_certification_type(@certification_type)
    @certifications = CertificationListPresenter.new(certifications_collection).present(_certified_params(params))
    @certifications_count = @certifications.count

    employees_collection = @employee_service.get_employees_not_certified_for(@certification_type)
    @non_certified_employees = EmployeeListPresenter.new(employees_collection).present(_noncertified_params(params))
    @non_certified_employee_count = @non_certified_employees.count
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

  def load_certification_type_service(service = CertificationTypeService.new)
    @certification_type_service ||= service
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end

  def load_employee_service(service = EmployeeService.new)
    @employee_service ||= service
  end

  private

  def _set_certification_type
    certification_type_pending_authorization = CertificationType.find(params[:id])
    authorize! :manage, certification_type_pending_authorization
    @certification_type = certification_type_pending_authorization
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