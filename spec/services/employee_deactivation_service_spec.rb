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
      equipment = create(:equipment, employee: employee)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      equipment.reload
      equipment.employee_id.should be_nil
    end

    it "does not unassign other employee's equipment" do
      employee = create_employee
      other_employee = create_employee
      equipment = create(:equipment, employee: other_employee)

      EmployeeDeactivationService.new.deactivate_employee(employee)

      equipment.reload
      equipment.employee_id.should == other_employee.id
    end
  end

  describe 'deactivated_employees' do
    before do
      @my_customer = create_customer
      @my_user = create_user(customer: @my_customer)
    end

    it 'includes only inactive employees' do
      inactive_employee = create_employee(active: false, customer: @my_customer)
      active_employee = create_employee(active: true, customer: @my_customer)

      results = EmployeeDeactivationService.new.get_deactivated_employees(@my_user)

      results.should == [inactive_employee]
    end

    it 'includes only inactive employees for customer' do
      my_inactive_employee = create_employee(active: false, customer: @my_customer)
      other_inactive_employee = create_employee(active: false, customer: create_customer)

      results = EmployeeDeactivationService.new.get_deactivated_employees(@my_user)

      results.should == [my_inactive_employee]
    end

    context 'pagination' do
      it 'should call PaginationService to paginate results' do
        employee_deactivation_service = EmployeeDeactivationService.new
        fake_pagination_service = employee_deactivation_service.load_pagination_service(FakeService.new)

        employee_deactivation_service.get_deactivated_employees(@my_user)

        fake_pagination_service.received_message.should == :paginate
      end
    end
  end
end
