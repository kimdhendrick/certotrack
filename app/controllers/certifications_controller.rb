class CertificationsController < ApplicationController

  before_filter :authenticate_user!,
                :load_certification_service,
                :load_certification_type_service,
                :load_employee_service

  check_authorization

  def new
    authorize! :create, :certification

    @source = params[:source]
    _set_certification_types(current_user)
    _set_new_certification(current_user, params[:employee_id], params[:certification_type_id])
    _set_employees(current_user)
  end

  def create
    authorize! :create, :certification

    return _render_new if params[:certification][:employee_id].blank?

    @certification = @certification_service.certify(
      current_user,
      params[:certification][:employee_id],
      params[:certification][:certification_type_id],
      params[:certification][:last_certification_date],
      params[:certification][:trainer],
      params[:certification][:comments],
      params[:certification][:units_achieved]
    )

    if !@certification.valid?
      return _render_new
    elsif _redirect_to_employee?
      redirect_to @certification.employee, notice: _success_message(@certification)
    elsif _redirect_to_certification_type?
      redirect_to @certification.certification_type, notice: _success_message(@certification)
    elsif _redirect_to_show_certification_page?
      redirect_to @certification, notice: _success_message(@certification)
    else
      return _render_new_with_message _success_message(@certification)
    end
  end

  def show
    _set_certification
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end

  def load_certification_type_service(service = CertificationTypeService.new)
    @certification_type_service ||= service
  end

  def load_employee_service(service = EmployeeService.new)
    @employee_service ||= service
  end


  private

  def _set_certification
    certification_pending_authorization = Certification.find(params[:id])
    authorize! :manage, certification_pending_authorization
    @certification = certification_pending_authorization
  end

  def _set_certification_types(current_user)
    certification_types = @certification_type_service.get_all_certification_types(current_user)
    @certification_types = CertificationTypeListPresenter.new(certification_types).sort
  end

  def _set_employees(current_user)
    employees = @employee_service.get_all_employees(current_user)
    @employees = EmployeeListPresenter.new(employees).sort
  end

  def _success_message(certification)
    "Certification: #{certification.name} created for #{EmployeePresenter.new(certification.employee).name}."
  end

  def _set_new_certification(current_user, employee_id, certification_type_id)
    @certification = @certification_service.new_certification(current_user, employee_id, certification_type_id)
  end

  def _redirect_to_employee?
    params[:commit] == 'Create' && params[:source] == 'employee'
  end

  def _redirect_to_certification_type?
    params[:commit] == 'Create' && params[:source] == 'certification_type'
  end

  def _redirect_to_show_certification_page?
    params[:commit] == 'Create' && params[:source] == 'certification'
  end

  def _render_new_with_message(message)
    flash[:notice] = message
    @source = params[:source]
    _set_certification_types(current_user)
    _set_new_certification(current_user, params[:certification][:employee_id], nil)
    render action: 'new'
    nil
  end

  def _render_new
    _set_certification_types(current_user)
    _set_employees(current_user)
    render action: 'new'
    nil
  end
end