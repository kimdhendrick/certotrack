require 'spec_helper'

describe EmployeeService do
  describe 'get_employee_list' do
    before do
      @my_customer = create_customer
      @my_user = create_user(customer: @my_customer)
    end

    context 'when admin user' do
      it 'should return all employees' do
        admin_user = create_user(roles: ['admin'])
        my_employee = create_employee(customer: @my_customer)
        other_employee = create_employee(customer: create_customer)

        EmployeeService.new.get_employee_list(admin_user).should == [my_employee, other_employee]
      end
    end

    context 'when regular user' do
      it "should return only customer's employees" do
        user = create_user(customer: @my_customer)
        my_employee = create_employee(customer: @my_customer)
        other_employee = create_employee(customer: create_customer)

        EmployeeService.new.get_employee_list(user).should == [my_employee]
      end

      it 'only returns active employees' do
        active_employee = create_employee(active: true, customer: @my_customer)
        inactive_employee = create_employee(active: false, customer: @my_customer)

        EmployeeService.new.get_employee_list(@my_user).should == [active_employee]
      end
    end

    context 'sorting' do
      it 'should call SortService to ensure sorting' do
        employee_service = EmployeeService.new
        fake_sort_service = employee_service.load_sort_service(FakeService.new([]))

        employee_service.get_employee_list(@my_user)

        fake_sort_service.received_message.should == :sort
      end

      it 'should default to sorted ascending by employee_number' do
        employee_service = EmployeeService.new
        fake_sort_service = employee_service.load_sort_service(FakeService.new([]))

        employee_service.get_employee_list(@my_user)

        fake_sort_service.received_message.should == :sort
        fake_sort_service.received_params[3].should == 'employee_number'
      end
    end

    context 'pagination' do
      it 'should call PaginationService to paginate results' do
        employee_service = EmployeeService.new
        employee_service.load_sort_service(FakeService.new)
        fake_pagination_service = employee_service.load_pagination_service(FakeService.new)

        employee_service.get_employee_list(@my_user)

        fake_pagination_service.received_message.should == :paginate
      end
    end
  end

  describe 'get_all_employees' do
    before do
      @my_customer = create_customer
      @my_user = create_user(customer: @my_customer)
    end

    context 'when admin user' do
      it 'should return all employees' do
        admin_user = create_user(roles: ['admin'])
        my_employee = create_employee(customer: @my_customer)
        other_employee = create_employee(customer: create_customer)

        EmployeeService.new.get_all_employees(admin_user).should == [my_employee, other_employee]
      end
    end

    context 'when regular user' do
      it "should return only customer's employees" do
        user = create_user(customer: @my_customer)
        my_employee = create_employee(customer: @my_customer)
        other_employee = create_employee(customer: create_customer)

        EmployeeService.new.get_all_employees(user).should == [my_employee]
      end

      it 'only returns active employees' do
        active_employee = create_employee(active: true, customer: @my_customer)
        inactive_employee = create_employee(active: false, customer: @my_customer)

        EmployeeService.new.get_all_employees(@my_user).should == [active_employee]
      end
    end
  end

  describe 'create_employee' do
    it 'should create employee' do
      attributes =
        {
          'first_name' => 'Kim',
          'last_name' => 'Ba',
          'employee_number' => 'KIMBA123',
          'location_id' => 99
        }
      customer = new_customer

      employee = EmployeeService.new.create_employee(customer, attributes)

      employee.should be_persisted
      employee.first_name.should == 'Kim'
      employee.last_name.should == 'Ba'
      employee.employee_number.should == 'KIMBA123'
      employee.location_id.should == 99
      employee.customer.should == customer
    end
  end

  describe 'update_employee' do
    it 'should update employees attributes' do
      employee = create_employee(customer: @customer)
      attributes =
        {
          'id' => employee.id,
          'first_name' => 'Susie',
          'last_name' => 'Sampson',
          'employee_number' => 'newEmpNum',
          'location_id' => 99
        }

      success = EmployeeService.new.update_employee(employee, attributes)
      success.should be_true

      employee.reload
      employee.first_name.should == 'Susie'
      employee.last_name.should == 'Sampson'
      employee.employee_number.should == 'newEmpNum'
      employee.location_id.should == 99
    end

    it 'should return false if errors' do
      employee = create_employee(customer: @customer)
      employee.stub(:save).and_return(false)

      success = EmployeeService.new.update_employee(employee, {})
      success.should be_false

      employee.reload
      employee.first_name.should_not == 'Susie'
    end
  end

  describe 'delete_employee' do
    it 'destroys the requested employee' do
      employee = create_employee(customer: @customer)

      expect {
        EmployeeService.new.delete_employee(employee)
      }.to change(Employee, :count).by(-1)
    end

    it 'returns error when equipment assigned to employee' do
      employee = create_employee(customer: @customer)
      equipment = create_equipment(employee: employee, customer: @customer)

      status = EmployeeService.new.delete_employee(employee)

      employee.reload
      employee.should_not be_nil

      equipment.reload
      equipment.should_not be_nil

      status.should == :equipment_exists
    end
  end
end