class AutoRecertificationsController < ApplicationController

  before_filter :authenticate_user!,
                :load_certification_service

  before_action :_set_certification_type, only: [:new, :create]

  #check_authorization

  def new
    @certifications = @certification_type.valid_certifications
  end

  def create
    unless params[:certification_ids] && params[:certification_ids].any?
      flash[:error] = 'Please select at least one certification.'
      redirect_to new_certification_type_auto_recertification_path
      return
    end

    result = @certification_service.auto_recertify(params[:certification_ids])

    if result == :success
      flash[:notice] = 'Auto Recertify successful.'
      redirect_to certification_type_url(@certification_type)
    else
      flash[:error] = 'A system error has occurred. Please contact support@certotrack.com.'
      redirect_to new_certification_type_auto_recertification_path(@certification_type)
    end
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end

  private

  def _set_certification_type
    certification_type_pending_authorization = CertificationType.find(params[:certification_type_id])
    authorize! :manage, certification_type_pending_authorization
    @certification_type = certification_type_pending_authorization
  end

  #def _success_message(certification)
  #  "#{EmployeePresenter.new(certification.employee).name} recertified for Certification: #{certification.name}."
  #end
end