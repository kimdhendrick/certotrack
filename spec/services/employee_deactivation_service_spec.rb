require 'spec_helper'

describe EmployeeDeactivationService do
  describe 'deactivate_employee' do
    it 'makes employee inactive' do
      employee = build(:employee, active: true)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      employee.should_not be_active
    end

    it "sets the employee's deactivation date" do
      employee = create(:employee, active: true, deactivation_date: nil)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      employee.reload
      employee.deactivation_date.should == Date.today
    end

    it 'unassigns equipment' do
      employee = create(:employee)
      equipment = create(:equipment, employee: employee)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      equipment.reload
      equipment.employee_id.should be_nil
    end

    it "does not unassign other employee's equipment" do
      employee = create(:employee)
      other_employee = create(:employee)
      equipment = create(:equipment, employee: other_employee)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      equipment.reload
      equipment.employee_id.should == other_employee.id
    end

    it "deactivates employee's certifications" do
      employee = create(:employee)
      certification = create(:certification, employee: employee, customer: employee.customer)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      certification.reload
      certification.should_not be_active
    end

    it "does not deactivate other employee's certifications" do
      employee = create(:employee)
      other_employee = create(:employee)
      certification = create(:certification, employee: employee, customer: employee.customer)
      other_certification = create(:certification, employee: other_employee, customer: other_employee.customer)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      certification.reload
      certification.should_not be_active

      other_certification.reload
      other_certification.should be_active
    end
  end

  describe 'deactivated_employees' do
    let(:my_customer) { create(:customer) }
    let(:my_user) { create(:user, customer: my_customer) }

    it 'includes only inactive employees' do
      inactive_employee = create(:employee, active: false, customer: my_customer)
      active_employee = create(:employee, active: true, customer: my_customer)

      results = EmployeeDeactivationService.new.get_deactivated_employees(my_user)

      results.should == [inactive_employee]
    end

    it 'includes only inactive employees for customer' do
      my_inactive_employee = create(:employee, active: false, customer: my_customer)
      other_inactive_employee = create(:employee, active: false)

      results = EmployeeDeactivationService.new.get_deactivated_employees(my_user)

      results.should == [my_inactive_employee]
    end

    context 'pagination' do
      it 'should call Paginator to paginate results' do
        fake_paginator = FakeService.new
        employee_deactivation_service = EmployeeDeactivationService.new(paginator: fake_paginator)

        employee_deactivation_service.get_deactivated_employees(my_user)

        fake_paginator.received_message.should == :paginate
      end
    end
  end
end
