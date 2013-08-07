require 'spec_helper'

describe EmployeeService do
  before do
    @my_customer = create_customer
    @my_employee = create_employee(customer: @my_customer)
    @other_employee = create_employee(customer: create_customer)
  end

  context 'when admin user' do
    it 'should return all employees' do
      admin_user = create_user(roles: ['admin'])

      EmployeeService.new.get_all_employees(admin_user).should == [@my_employee, @other_employee]
    end
  end

  context 'when regular user' do
    it "should return only customer's employees" do
      user = create_user(customer: @my_customer)

      EmployeeService.new.get_all_employees(user).should == [@my_employee]
    end
  end
end