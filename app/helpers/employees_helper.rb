module EmployeesHelper

  def employee_presenter_for(employee = @employee)
    presenter = EmployeePresenter.new(employee)
    if block_given?
      yield presenter
    else
      presenter
    end
  end

  def employees_accessible_parameters
    [
      :first_name,
      :last_name,
      :employee_number,
      :location_id
    ]
  end
end