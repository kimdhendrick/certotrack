class EmployeesController < ApplicationController
  include EmployeesHelper

  before_filter :authenticate_user!,
                :load_employee_service,
                :load_location_service

  before_action :_set_employee, only: [:show, :edit, :update, :destroy]

  check_authorization

  def show
  end

  def new
    authorize! :create, :certification
    @locations = @location_service.get_all_locations(current_user)
    @employee = Employee.new
  end

  def create
    authorize! :create, :certification

    @employee = @employee_service.create_employee(current_user.customer, _employees_params)

    if @employee.persisted?
      redirect_to @employee, notice: 'Employee was successfully created.'
    else
      @locations = @location_service.get_all_locations(current_user)
      render action: 'new'
    end
  end

  def load_employee_service(service = EmployeesService.new)
    @employee_service ||= service
  end

  def load_location_service(service = LocationService.new)
    @location_service ||= service
  end

  private

  def _set_employee
    employee_pending_authorization = Employee.find(params[:id])
    authorize! :manage, employee_pending_authorization
    @equipment = employee_pending_authorization
  end

  def _employees_params
    params.require(:employee).permit(employees_accessible_parameters)
  end

end