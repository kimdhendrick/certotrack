class EmployeesController < ModelController
  include EmployeesHelper
  include ControllerHelper
  include PresentableModelHelper

  before_filter :load_employee_service,
                :load_location_service,
                :load_certification_service

  before_action :_set_employee, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, :certification

    employees_collection = @employee_service.get_all_employees(current_user)
    @employees = EmployeeListPresenter.new(employees_collection).present(params)
    @employee_count = @employees.count
  end

  def show
    assign_certifications_by_employee(params)
  end

  def new
    authorize! :create, :certification
    _set_locations
    @employee = Employee.new
  end

  def create
    authorize! :create, :certification

    @employee = @employee_service.create_employee(current_user.customer, _employees_params)

    if @employee.persisted?
      redirect_to @employee, notice: 'Employee was successfully created.'
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
      redirect_to @employee, notice: 'Employee was successfully updated.'
    else
      _set_locations
      render action: 'edit'
    end
  end

  def destroy
    status = @employee_service.delete_employee(@employee)

    if status == :equipment_exists
      redirect_to @employee, notice: 'Employee has equipment assigned, you must remove them before deleting the employee. Or Deactivate the employee instead.'
      return
    end

    if status == :certification_exists
      redirect_to @employee, notice: 'Employee has certifications, you must remove them before deleting the employee. Or Deactivate the employee instead.'
      return
    end

    redirect_to employees_url, notice: 'Employee was successfully deleted.'
  end

  private

  def _set_locations
    @locations = LocationListPresenter.new(@location_service.get_all_locations(current_user)).sort
  end

  def _set_employee
    _set_model(Employee)
    @employee = @model
  end

  def _employees_params
    params.require(:employee).permit(employees_accessible_parameters)
  end
end