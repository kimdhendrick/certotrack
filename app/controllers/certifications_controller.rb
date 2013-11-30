class CertificationsController < ModelController
  include ControllerHelper
  include CertificationsHelper
  include CertificationTypesHelper
  include PresentableModelHelper

  before_filter :load_certification_service,
                :load_certification_type_service,
                :load_employee_service,
                :load_location_service

  before_action :_set_certification,
                only: [:show, :edit, :update, :destroy, :certification_history]

  def index
    authorize! :read, :certification

    @report_title = 'All Employee Certifications'
    _render_certifications(@certification_service.get_all_certifications(current_user))
  end

  def expired
    authorize! :read, :certification

    @report_title = 'Expired Certifications'
    _render_certifications(@certification_service.get_expired_certifications(current_user))
  end

  def expiring
    authorize! :read, :certification

    @report_title = 'Certifications Expiring Soon'
    _render_certifications(@certification_service.get_expiring_certifications(current_user))
  end

  def units_based
    authorize! :read, :certification

    @report_title = 'Units Based Certifications'
    _render_certifications(@certification_service.get_units_based_certifications(current_user))
  end

  def recertification_required
    authorize! :read, :certification

    @report_title = 'Recertification Required Certifications'
    _render_certifications(@certification_service.get_recertification_required_certifications(current_user))
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

  def search
    authorize! :read, :certification
    @report_title = 'Search Certifications'
    certification_collection = @certification_service.search_certifications(current_user, params)
    @certifications = CertificationListPresenter.new(certification_collection).present(params)
    @certification_count = @certifications.count
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort
    @certification_types = get_certification_type_types
  end

  private

  def _render_certifications(certifications_collection)
    @certifications = CertificationListPresenter.new(certifications_collection).present(params)
    @certification_count = @certifications.count
    render 'certifications/index'
  end

  def _set_certification
    _set_model(Certification)
    @certification = @model
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