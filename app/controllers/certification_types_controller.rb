class CertificationTypesController < ApplicationController
  include ControllerHelper
  include CertificationTypesHelper

  before_filter :authenticate_user!,
                :load_certification_type_service

  before_action :set_certification_type, only: [:show, :edit, :update, :destroy]

  check_authorization

  def index
    authorize! :read, :certification

    @certification_types = @certification_type_service.get_certification_type_list(current_user, params)
    @certification_types_count = @certification_types.count
  end

  def show
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
    @certification_type_service.delete_certification_type(@certification_type)
    redirect_to certification_types_path, notice: 'Certification Type was successfully deleted.'
  end

  def search
    authorize! :read, :certification
    @certification_types = @certification_type_service.get_certification_type_list(current_user, params)
    @certification_types_count = @certification_types.count
  end

  def load_certification_type_service(service = CertificationTypeService.new)
    @certification_type_service ||= service
  end

  private

  def set_certification_type
    certification_type_pending_authorization = CertificationType.find(params[:id])
    authorize! :manage, certification_type_pending_authorization
    @certification_type = certification_type_pending_authorization
  end

  def _certification_type_params
    params.require(:certification_type).permit(certification_type_accessible_parameters)
  end
end