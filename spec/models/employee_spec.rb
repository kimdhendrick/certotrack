require 'spec_helper'

describe Employee do
  before { @employee = new_employee }

  subject { @employee }

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :employee_number }

  it { should belong_to(:customer) }
  it { should belong_to(:location) }

  it 'should display its name as to_s' do
    @employee.first_name = 'John'
    @employee.last_name = 'Doe'
    @employee.to_s.should == 'Doe, John'
  end

  it 'should respond to location_name' do
    location = create_location(name: 'Location Name')
    employee = create_employee(location_id: location.id)

    employee.location_name.should == 'Location Name'
  end

  it 'should default active to true' do
    employee = Employee.new
    employee.active.should be_true
  end
end