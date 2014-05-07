class BatchCertificationsController < ModelController
  include AuthorizationHelper

  before_action :load_batch_certification

  def create
    authorize! :read, :certification

    _authorize_certifications(batch_certification.certifications)

    if !batch_certification.update
      _handle_error(batch_certification)
      return
    end

    flash[:notice] = 'Certifications updated successfully.'

    if batch_certification.employee_update?
      redirect_to employee_path(params[:employee_id]) and return
    else
      redirect_to certification_type_path(params[:certification_type_id]) and return
    end
  end

  def load_batch_certification(instance = nil)
    @batch_certification ||= (instance || BatchCertification.new(params))
  end

  private

  attr_reader :batch_certification

  def _handle_error(batch_certification)
    @certifications = batch_certification.certifications
    @batch_certification = batch_certification

    if batch_certification.employee_update?
      @employee = batch_certification.employee
      @model = @employee
      render 'employees/show'
    else
      @certification_type = batch_certification.certification_type
      @model = @certification_type
      @certifications_count = @certifications.count
      @non_certified_employees = batch_certification.non_certified_employees
      @non_certified_employee_count = @non_certified_employees.count
      render 'certification_types/show'
    end
  end

  def _authorize_certifications(certifications)
    authorize_all(certifications.map(&:model), :manage)
  end
end