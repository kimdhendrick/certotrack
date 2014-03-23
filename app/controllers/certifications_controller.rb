class CertificationsController < ModelController
  include ControllerHelper
  include CertificationsHelper
  include CertificationTypesHelper

  before_filter :load_certification_service,
                :load_certification_type_service,
                :load_employee_service,
                :load_location_service

  before_action :_set_certification,
                only: [:show, :edit, :update, :destroy, :certification_history]

  def index
    _render_certification_list(:all, 'All Employee Certifications')
  end
  
  def expired
    _render_certification_list(:expired, 'Expired Certifications')
  end

  def expiring
    _render_certification_list(:expiring, 'Certifications Expiring Soon')
  end

  def units_based
    _render_certification_list(:units_based, 'Units Based Certifications')
  end

  def recertification_required
    _render_certification_list(:recertification_required, 'Recertification Required Certifications')
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
      _set_certification_types(current_user)
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

    certification_collection = @certification_service.search_certifications(current_user, params)

    _render_search('Search Certifications', certification_collection)
  end

  private

  def _render_certification_list(certification_type, report_title)
    authorize! :read, :certification

    certification_collection = @certification_service.public_send("get_#{certification_type}_certifications", current_user)

    @export_template = "#{certification_type.to_s}_certification_export"

    respond_to do |format|
      format.html { _render_certification_list_as_html(report_title, certification_collection) }
      format.csv { _render_collection_as_csv(certification_collection) }
      format.xls { _render_collection_as_xls(report_title, certification_type, certification_collection) }
      format.pdf { _render_collection_as_pdf(report_title, certification_type, certification_collection) }
    end
  end

  def _render_certification_list_as_html(report_title, certification_collection)
    @report_title = report_title
    @certifications = CertificationListPresenter.new(certification_collection).present(params)
    @certification_count = certification_collection.count
    render 'certifications/index'
  end

  def _filename(report_type, extension)
    report_type == :all ? "certifications.#{extension}" : "#{report_type}_certifications.#{extension}"
  end

  def _render_search_collection_as_html(certification_collection)
    @export_template = 'search_certification_export'
    @report_title = 'Search Certifications'
    @certifications = CertificationListPresenter.new(certification_collection).present(params)
    @certification_count = certification_collection.count
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort
    @certification_types = get_certification_type_types
    employees_collection = @employee_service.get_all_employees(current_user)
    @employees = EmployeeListPresenter.new(employees_collection).present({sort: :sort_key})
  end

  def _set_certification
    @certification = _get_model(Certification)
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