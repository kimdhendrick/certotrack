require 'spec_helper'

describe EmployeesService do
  describe 'get_all_employees' do
    before do
      @my_customer = create_customer
      @my_user = create_user(customer: @my_customer)
      @my_employee = create_employee(customer: @my_customer)
      @other_employee = create_employee(customer: create_customer)
    end

    context 'when admin user' do
      it 'should return all employees' do
        admin_user = create_user(roles: ['admin'])

        EmployeesService.new.get_all_employees(admin_user).should == [@my_employee, @other_employee]
      end
    end

    context 'when regular user' do
      it "should return only customer's employees" do
        user = create_user(customer: @my_customer)

        EmployeesService.new.get_all_employees(user).should == [@my_employee]
      end
    end

    context 'sorting' do
      it 'should call SortService to ensure sorting' do
        employee_service = EmployeesService.new
        fake_sort_service = employee_service.load_sort_service(FakeService.new([]))

        employee_service.get_all_employees(@my_user)

        fake_sort_service.received_message.should == :sort
      end

      it 'should default to sorted ascending by employee_number' do
        employee_service = EmployeesService.new
        fake_sort_service = employee_service.load_sort_service(FakeService.new([]))

        employee_service.get_all_employees(@my_user)

        fake_sort_service.received_message.should == :sort
        fake_sort_service.received_params[3].should == 'employee_number'
      end
    end

    context 'pagination' do
      it 'should call PaginationService to paginate results' do
        employee_service = EmployeesService.new
        employee_service.load_sort_service(FakeService.new)
        fake_pagination_service = employee_service.load_pagination_service(FakeService.new)

        employee_service.get_all_employees(@my_user)

        fake_pagination_service.received_message.should == :paginate
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

      employee = EmployeesService.new.create_employee(customer, attributes)

      employee.should be_persisted
      employee.first_name.should == 'Kim'
      employee.last_name.should == 'Ba'
      employee.employee_number.should == 'KIMBA123'
      employee.location_id.should == 99
      employee.customer.should == customer
    end
  end
end