require 'spec_helper'

describe EmployeeDeactivationController do
  before do
    @customer = create_customer
  end

  describe 'GET deactivate' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'calls EmployeesService' do
        employee = create_employee(customer: @customer)
        @fake_employee_service = controller.load_employee_deactivation_service(FakeService.new(true))

        delete :deactivate, {:id => employee.to_param}, {}

        @fake_employee_service.received_message.should == :deactivate_employee
        @fake_employee_service.received_params[0].should == employee
      end

      it 'redirects to the employee list' do
        employee = create_employee(customer: @customer, last_name: 'last', first_name: 'first')
        @fake_employee_service = controller.load_employee_deactivation_service(FakeService.new(true))

        delete :deactivate, {:id => employee.to_param}, {}

        response.should redirect_to(employees_url)
        flash[:notice].should == 'Employee last, first deactivated'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls EmployeesService' do
        employee = create_employee(customer: @customer)
        @fake_employee_service = controller.load_employee_deactivation_service(FakeService.new(true))

        delete :deactivate, {:id => employee.to_param}, {}
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not deactivate' do
        employee = new_employee
        @fake_employee_service = controller.load_employee_deactivation_service(FakeService.new([employee]))

        get :deactivated_employees

        @fake_employee_service.received_message.should be_nil
      end
    end
  end

  describe 'GET deactivate_confirm' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'calls service and makes assignments' do
        employee = create_employee(customer: @customer)
        equipment = new_equipment
        @fake_equipment_service = controller.load_equipment_service(FakeService.new([equipment]))

        get :deactivate_confirm, {:id => employee.to_param}, {}

        assigns(:employee).should eq(employee)
        assigns(:equipments).should eq([equipment])
        @fake_equipment_service.received_message.should == :get_all_equipment_for_employee
        @fake_equipment_service.received_params[0].should == employee
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls service and makes assignments' do
        employee = create_employee(customer: @customer)
        equipment = new_equipment
        @fake_equipment_service = controller.load_equipment_service(FakeService.new([equipment]))

        get :deactivate_confirm, {:id => employee.to_param}, {}

        assigns(:employee).should eq(employee)
        assigns(:equipments).should eq([equipment])
        @fake_equipment_service.received_message.should == :get_all_equipment_for_employee
        @fake_equipment_service.received_params[0].should == employee
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign anything' do
        employee = create_employee(customer: @customer)

        get :deactivate_confirm, {:id => employee.to_param}, {}

        assigns(:employee).should be_nil
        assigns(:equipments).should be_nil
      end
    end
  end

  describe 'GET deactivated_employees' do
    it 'calls get_deactivated_employees with current_user and params' do
      my_user = stub_certification_user
      sign_in my_user
      @fake_employee_service = controller.load_employee_deactivation_service(FakeService.new([]))
      params = {}

      get :deactivated_employees, params

      @fake_employee_service.received_messages.should == [:get_deactivated_employees]
      @fake_employee_service.received_params[0].should == my_user
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns @employees and @employee_count' do
        employee = new_employee
        @fake_employee_service = controller.load_employee_deactivation_service(FakeService.new([employee]))

        get :deactivated_employees

        assigns(:employees).should eq([employee])
        assigns(:employee_count).should eq(1)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns employees as @employees' do
        employee = new_employee
        @fake_employee_service = controller.load_employee_deactivation_service(FakeService.new([employee]))

        get :deactivated_employees

        assigns(:employees).should eq([employee])
        assigns(:employee_count).should eq(1)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employees as @employees' do
        employee = new_employee
        @fake_employee_service = controller.load_employee_deactivation_service(FakeService.new([employee]))

        get :deactivated_employees

        assigns(:employees).should be_nil
        assigns(:employee_count).should be_nil
      end
    end
  end
end