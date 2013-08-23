class CertificationTypesController < ApplicationController
  include ControllerHelper
  include CertificationTypesHelper

  before_filter :authenticate_user!,
                :load_certification_type_service

  before_action :set_certification_type, only: [:show, :edit, :update, :destroy]

  check_authorization

  def index
    authorize! :read, :certification
  end

  def show
  end

  def new
    authorize! :create, :certification
    @certification_type = CertificationType.new
    assign_intervals
  end

  def create
    authorize! :create, :certification

    @certification_type =
      @certification_type_service.create_certification_type(
        current_user.customer,
        _certification_type_params)

    if @certification_type.save
      redirect_to @certification_type, notice: 'Certification Type was successfully created.'
    else
      assign_intervals
      render action: 'new'
    end
  end

  def destroy
  end

  def load_certification_type_service(service = CertificationTypesService.new)
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