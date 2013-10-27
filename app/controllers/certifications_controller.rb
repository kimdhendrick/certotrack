class CertificationsController < ApplicationController
  include CertificationsHelper

  before_filter :authenticate_user!,
                :load_certification_service,
                :load_certification_type_service,
                :load_employee_service

  before_action :_set_certification,
                only: [:show, :edit, :update, :destroy, :recertify, :save_recertification, :certification_history]

  check_authorization

  def index
    authorize! :read, :certification

    @report_title = 'All Employee Certifications'
    certifications_collection = @certification_service.get_all_certifications(current_user)
    @certifications = CertificationListPresenter.new(certifications_collection).present(params)
    @certification_count = @certifications.count
  end

  def new
    authorize! :create, :certification

    @source = params[:source]
    _set_certification_types(current_user)
    _set_new_certification(current_user, params[:employee_id], params[:certification_type_id])
    _set_employees(current_user)
  end

  def create
    authorize! :create, :certification

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
    else
      return _render_new_with_message _success_message(@certification)
    end
  end

  def show
  end

  def edit
    authorize! :create, :certification
    _set_certification_types(current_user)
  end

  def update
    success = @certification_service.update_certification(@certification, _certification_params)

    if success
      redirect_to @certification.certification_type, notice: 'Certification was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    certification_type = @certification.certification_type
    employee = @certification.employee
    @certification_service.delete_certification(@certification)
    redirect_to certification_type, notice: "Certification for #{employee.last_name}, #{employee.first_name} deleted."
  end

  def certification_history
    @certification_periods = CertificationPeriodListPresenter.new(@certification.certification_periods).present
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
    params[:commit] == 'Create' &&
      (params[:source] == 'certification_type' || params[:source] == 'certification')
  end

  def _render_new_with_message(message = nil)
    flash[:notice] = message
    _set_new_certification(current_user, params[:certification][:employee_id], nil)
    _render_new
  end

  def _render_new
    @source = params[:source]
    _set_certification_types(current_user)
    _set_employees(current_user)
    render action: 'new'
    nil
  end

  def _certification_params
    params.require(:certification).permit(certification_accessible_parameters)
  end
end