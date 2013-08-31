require 'spec_helper'

describe EmployeeDeactivationService do
  describe 'deactivate_employee' do
    it 'makes employee inactive' do
      employee = new_employee(active: true)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      employee.should_not be_active
    end

    it "sets the employee's deactivation date" do
      employee = create_employee(active: true, deactivation_date: nil)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      employee.reload
      employee.deactivation_date.should == Date.today
    end

    it 'unassigns equipment' do
      employee = create_employee
      equipment = create_equipment(employee: employee)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      equipment.reload
      equipment.employee_id.should be_nil
    end

    it "does not unassign other employee's equipment" do
      employee = create_employee
      other_employee = create_employee
      equipment = create_equipment(employee: other_employee)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      equipment.reload
      equipment.employee_id.should == other_employee.id
    end
  end
end
