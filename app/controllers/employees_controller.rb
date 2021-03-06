class EmployeesController < ModelController
  include EmployeesHelper
  include ControllerHelper

  before_filter :load_employee_service,
                :load_location_service,
                :load_certification_service

  before_action :_set_employee, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, :certification

    employees_collection = @employee_service.get_all_employees(current_user)
    @employees = EmployeeListPresenter.new(employees_collection).present(params)
    @employee_count = employees_collection.count
  end

  def show
    certifications_for_employee = @certification_service.get_all_certifications_for_employee(@employee)

    respond_to do |format|
      format.html do
        @certifications = CertificationListPresenter.new(certifications_for_employee).present(params)
        @total_certifications = certifications_for_employee.count
      end
      format.csv { _render_collection_as_csv('employee_certifications', certifications_for_employee) }
      format.xls { _render_collection_as_xls('Employee Certifications', :employee_certifications, certifications_for_employee) }
      format.pdf { _render_collection_as_pdf('Employee Certifications', :employee_certifications, certifications_for_employee) }
    end
  end

  def new
    authorize! :create, :certification
    _set_locations
    @employee = Employee.new
  end

  def create
    authorize! :create, :certification

    @employee = @employee_service.create_employee(current_user.customer, _employees_params_for_create)

    if @employee.persisted?
      flash[:success] = "Employee #{EmployeePresenter.new(@employee).name} was successfully created."
      redirect_to @employee
    else
      _set_locations
      render action: 'new'
    end
  end

  def edit
    _set_locations
  end

  def update
    success = @employee_service.update_employee(@employee, _employees_params)

    if success
      flash[:success] = "Employee #{EmployeePresenter.new(@employee).name} was successfully updated."
      redirect_to @employee
    else
      _set_locations
      render action: 'edit'
    end
  end

  def destroy
    if @employee_service.delete_employee(@employee)
      flash[:success] = "Employee #{EmployeePresenter.new(@employee).name} was successfully deleted."
      redirect_to employees_url
    else
      assign_certifications_by_employee(params)
      render :show
    end
  end

  private

  def _set_locations
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort
  end

  def _set_employee
    @employee = _get_model(Employee)
  end

  def _employees_params_for_create
    merge_created_by(_employees_params)
  end

  def _employees_params
    merge_created_by(
      params.require(:employee).
        permit(employees_accessible_parameters))
  end
end