require 'spec_helper'

describe EmployeePresenter do

  let(:employee) { build(:employee) }

  it 'should respond to model' do
    EmployeePresenter.new(employee).model.should == employee
  end

  it 'should respond to id' do
    EmployeePresenter.new(employee).id.should == employee.id
  end

  it 'should respond to first_name' do
    employee.first_name = 'Kim'
    EmployeePresenter.new(employee).first_name.should == 'Kim'
  end

  it 'should respond to last_name' do
    employee.last_name = 'Smith'
    EmployeePresenter.new(employee).last_name.should == 'Smith'
  end

  it 'should respond to employee_number' do
    employee.employee_number = '123ABC'
    EmployeePresenter.new(employee).employee_number.should == '123ABC'
  end

  it 'should respond to location_id' do
    employee.location_id = 123
    EmployeePresenter.new(employee).location_id.should == 123
  end

  it 'should respond to name' do
    employee.first_name = 'John'
    employee.last_name = 'Doe'
    EmployeePresenter.new(employee).name.should == 'Doe, John'
  end

  it 'should respond to location_name' do
    location = create(:location, name: 'Location Name')
    employee = create(:employee, location_id: location.id)

    EmployeePresenter.new(employee).location_name.should == 'Location Name'
  end

  it 'should respond to errors' do
    employee.customer = nil
    employee.should_not be_valid
    EmployeePresenter.new(employee).errors.should == employee.errors
  end

  it 'should respond to error count' do
    employee.customer = nil
    employee.should_not be_valid
    EmployeePresenter.new(employee).error_count.should == employee.errors.count
  end


end