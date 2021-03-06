require 'spec_helper'

describe EmployeeService do
  let(:my_customer) { create(:customer) }
  let(:my_user) { create(:user, customer: my_customer) }
  let(:admin_user) { create(:user, admin: true) }

  describe 'get_all_employees' do
    context 'when admin user' do
      it 'should return all employees' do
        my_employee = create(:employee, customer: my_customer)
        other_employee = create(:employee)

        EmployeeService.new.get_all_employees(admin_user).should =~ [my_employee, other_employee]
      end
    end

    context 'when regular user' do
      it "should return only customer's employees" do
        my_employee = create(:employee, customer: my_customer)
        other_employee = create(:employee)

        EmployeeService.new.get_all_employees(my_user).should == [my_employee]
      end

      it 'only returns active employees' do
        active_employee = create(:employee, active: true, customer: my_customer)
        inactive_employee = create(:employee, active: false, customer: my_customer)

        EmployeeService.new.get_all_employees(my_user).should == [active_employee]
      end
    end
  end

  describe '#find' do
    context 'when an admin user' do
      it 'should return all employees' do
        my_employee = create(:employee, customer: my_customer)
        other_employee = create(:employee)

        EmployeeService.new.find([my_employee.id, other_employee.id], admin_user).should =~ [my_employee, other_employee]
      end
    end

    context 'when a regular user' do
      it "should return only that user's employees" do
        my_employee = create(:employee, customer: my_customer)
        other_employee = create(:employee)

        EmployeeService.new.find([my_employee.id, other_employee.id], my_user).should == [my_employee]
      end
    end
  end

  describe '#create_employee' do
    let(:location) { create(:location) }

    it 'should create employee' do
      attributes =
        {
          'first_name' => 'Kim',
          'last_name' => 'Ba',
          'employee_number' => 'KIMBA123',
          'location_id' => location.id,
          'created_by' => 'kimba'
        }
      customer = build(:customer)

      employee = EmployeeService.new.create_employee(customer, attributes)

      employee.should be_persisted
      employee.first_name.should == 'Kim'
      employee.last_name.should == 'Ba'
      employee.employee_number.should == 'KIMBA123'
      employee.location_id.should == location.id
      employee.customer.should == customer
    end
  end

  describe '#update_employee' do
    let(:location) { create(:location) }

    it 'should update employees attributes' do
      employee = create(:employee, customer: my_customer)
      attributes =
        {
          'id' => employee.id,
          'first_name' => 'Susie',
          'last_name' => 'Sampson',
          'employee_number' => 'newEmpNum',
          'location_id' => location.id
        }

      success = EmployeeService.new.update_employee(employee, attributes)
      success.should be_true

      employee.reload
      employee.first_name.should == 'Susie'
      employee.last_name.should == 'Sampson'
      employee.employee_number.should == 'newEmpNum'
      employee.location_id.should == location.id
    end

    it 'should return false if errors' do
      employee = create(:employee, customer: my_customer)
      employee.stub(:save).and_return(false)

      success = EmployeeService.new.update_employee(employee, {})
      success.should be_false

      employee.reload
      employee.first_name.should_not == 'Susie'
    end
  end

  describe '#delete_employee' do
    it 'destroys the requested employee' do
      employee = create(:employee, customer: my_customer)

      expect {
        EmployeeService.new.delete_employee(employee)
      }.to change(Employee, :count).by(-1)
    end
  end

  describe '#get_employees_not_certified_for' do
    context 'when regular user' do
      it 'should return empty list when no employees' do
        certification_type = create(:certification_type, customer: my_customer)
        EmployeeService.new.get_employees_not_certified_for(certification_type).should == []
      end

      it 'should return empty list when all employees certified' do
        certification_type = create(:certification_type, customer: my_customer)
        certified_employee1 = create(:employee, customer: my_customer)
        certified_employee2 = create(:employee, customer: my_customer)
        create(:certification, employee: certified_employee1, certification_type: certification_type, customer: my_customer)
        create(:certification, employee: certified_employee2, certification_type: certification_type, customer: my_customer)

        EmployeeService.new.get_employees_not_certified_for(certification_type).should == []
      end

      it "should return only customer's employees" do
        certification_type = create(:certification_type, customer: my_customer)
        my_employee = create(:employee, customer: my_customer)
        other_employee = create(:employee)

        EmployeeService.new.get_employees_not_certified_for(certification_type).should == [my_employee]
      end

      it "should return only customer's employees when some are assigned" do
        certification_type = create(:certification_type, customer: my_customer)
        my_employee = create(:employee, customer: my_customer)
        another_certified_employee = create(:employee, customer: my_customer)
        create(:certification, employee: another_certified_employee, certification_type: certification_type, customer: my_customer)
        other_employee = create(:employee)

        EmployeeService.new.get_employees_not_certified_for(certification_type).should == [my_employee]
      end

      it 'only returns uncertified employees' do
        certification_type = create(:certification_type, customer: my_customer)
        certified_employee = create(:employee, last_name: 'certified', customer: my_customer)
        create(:certification, employee: certified_employee, certification_type: certification_type, customer: my_customer)
        uncertified_employee = create(:employee, last_name: 'UNCERTIFIED', customer: my_customer)

        EmployeeService.new.get_employees_not_certified_for(certification_type).should == [uncertified_employee]
      end

      it 'should return all employees' do
        certification_type = create(:certification_type, customer: my_customer)
        uncertified_employee1 = create(:employee, customer: my_customer)
        uncertified_employee2 = create(:employee, customer: my_customer)
        EmployeeService.new.get_employees_not_certified_for(certification_type).should == [uncertified_employee1, uncertified_employee2]
      end
    end

    context 'when admin user should still limit to customer' do
      it "should return only customer's employees" do
        certification_type = create(:certification_type, customer: my_customer)
        my_employee = create(:employee, customer: my_customer)
        other_employee = create(:employee)

        EmployeeService.new.get_employees_not_certified_for(certification_type).should == [my_employee]
      end

      it 'only returns uncertified employees' do
        certification_type = create(:certification_type, customer: my_customer)
        certified_employee = create(:employee, last_name: 'certified', customer: my_customer)
        create(:certification, employee: certified_employee, certification_type: certification_type, customer: my_customer)
        uncertified_employee = create(:employee, last_name: 'UNCERTIFIED', customer: my_customer)

        EmployeeService.new.get_employees_not_certified_for(certification_type).should == [uncertified_employee]
      end
    end
  end
end