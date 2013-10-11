class BatchCertificationsController < ApplicationController
  before_filter :authenticate_user!

  check_authorization

  def create
    authorize! :read, :certification

    batch_certification = load_batch_certification

    _authorize_certifications(batch_certification.certifications)

    success = batch_certification.update

    if !success
      @batch_certification = batch_certification
      @certifications = batch_certification.certifications
      @employee = batch_certification.employee
      render 'employees/show'
      return
    end

    flash[:notice] = 'Certifications updated successfully.'
    redirect_to employee_path(params[:employee_id]) and return
  end

  def load_batch_certification(instance = nil)
    @batch_certification ||= (instance || BatchCertification.new(params))
  end

  private

  def _authorize_certifications(certifications)
    certifications.map(&:model).each do |certification|
      authorize! :manage, certification
    end
  end
end