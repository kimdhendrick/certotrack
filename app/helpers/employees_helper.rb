module EmployeesHelper

  def employees_accessible_parameters
    [
      :first_name,
      :last_name,
      :employee_number,
      :location_id
    ]
  end
end