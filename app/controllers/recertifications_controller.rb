class RecertificationsController < ApplicationController

  before_filter :authenticate_user!,
    :load_certification_service

  before_action :_set_certification, only: [:new, :create]

  check_authorization

  def new
  end

  def create
    certification_period_params = {certification: @certification,
                                   start_date: params[:last_certification_date],
                                   trainer: params[:trainer],
                                   comments: params[:comments],
                                   units_achieved: params[:units_achieved]}
    success = @certification_service.recertify(@certification, certification_period_params)                                  

    if success
      redirect_to @certification, notice: _success_message(@certification)
    else
      render action: :new
    end
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end

  private

  def _set_certification
    certification_pending_authorization = Certification.find(params[:certification_id])
    authorize! :manage, certification_pending_authorization
    @certification = certification_pending_authorization
  end

  def _success_message(certification)
    "#{EmployeePresenter.new(certification.employee).name} recertified for Certification: #{certification.name}."
  end
end