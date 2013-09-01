class CertificationsController < ApplicationController

  before_filter :authenticate_user!,
                :load_certification_service,
                :load_certification_type_service

  check_authorization

  def new
    authorize! :create, :certification

    _set_certification_types(current_user)
    _set_new_certification(params[:employee_id])
  end

  def create
    authorize! :create, :certification

    @certification = @certification_service.certify(
      params[:employee][:id],
      params[:certification][:certification_type_id],
      params[:certification][:last_certification_date],
      params[:certification][:trainer],
      params[:certification][:comments]
    )

    if !@certification.valid?
      _set_certification_types(current_user)
      render action: 'new'
      return
    end

    if _redirect_to_employee?
      redirect_to @certification.employee, notice: _success_message(@certification)
    else
      flash[:notice] = _success_message(@certification)
      _set_new_certification(params[:employee][:id])
      _set_certification_types(current_user)
      render action: 'new'
    end
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end

  def load_certification_type_service(service = CertificationTypeService.new)
    @certification_type_service ||= service
  end


  private

  def _set_certification_types(current_user)
    @certification_types = @certification_type_service.get_all_certification_types(current_user)
  end

  def _success_message(certification)
    "Certification: #{certification.certification_type.name} created for #{certification.employee}."
  end

  def _set_new_certification(employee_id)
    @certification = @certification_service.new_certification(employee_id)
  end

  def _redirect_to_employee?
    params[:commit] == "Create"
  end
end