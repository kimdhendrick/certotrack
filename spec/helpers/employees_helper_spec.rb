require 'spec_helper'

describe EmployeesHelper do

  it "should provide employees's accessible parameters" do
    employees_accessible_parameters.should == [
      :first_name,
      :last_name,
      :employee_number,
      :location_id
    ]
  end
end