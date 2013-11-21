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

  it 'should respond true to show_batch_edit_button?' do
    certification_type = create(:certification_type, units_required: 10, customer: create(:customer))
    certification = build(:certification, employee: employee, certification_type: certification_type)
    EmployeePresenter.new(employee).show_batch_edit_button?([certification]).should be_true
  end

  it 'should respond false to show_batch_edit_button? when no units based certifications' do
    certification_type = create(:certification_type, units_required: 0, customer: create(:customer))
    certification = build(:certification, employee: employee, certification_type: certification_type)
    EmployeePresenter.new(employee).show_batch_edit_button?([certification]).should be_false
  end

  it 'should respond false to show_batch_edit_button? when no certifications' do
    EmployeePresenter.new(employee).show_batch_edit_button?([]).should be_false
  end
end