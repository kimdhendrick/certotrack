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

    if params[:certification][:certification_type_id].blank?
      return _render_new_with_message 'No certification type selected'
    end

    @certification = @certification_service.certify(
      params[:employee][:id],
      params[:certification][:certification_type_id],
      params[:certification][:last_certification_date],
      params[:certification][:trainer],
      params[:certification][:comments]
    )

    if !@certification.valid?
      return _render_new
    end

    if _redirect_to_employee?
      redirect_to @certification.employee, notice: _success_message(@certification)
    else
      return _render_new_with_message _success_message(@certification)
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
    "Certification: #{certification.name} created for #{certification.employee}."
  end

  def _set_new_certification(employee_id)
    @certification = @certification_service.new_certification(employee_id)
  end

  def _redirect_to_employee?
    params[:commit] == "Create"
  end

  def _render_new_with_message(message)
    flash[:notice] = message
    _set_certification_types(current_user)
    _set_new_certification(params[:employee][:id])
    render action: 'new'
    nil
  end

  def _render_new
    _set_certification_types(current_user)
    render action: 'new'
    nil
  end
end