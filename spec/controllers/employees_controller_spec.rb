require 'spec_helper'

describe EmployeesController do
  before do
    @customer = create_customer
  end

  describe 'GET new' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns a new employee as @employee' do
        get :new, {}, valid_session
        assigns(:employee).should be_a_new(Employee)
      end

      it 'assigns locations' do
        location = new_location
        LocationService.any_instance.stub(:get_all_locations).and_return([location])

        get :new

        assigns(:locations).should == [location]
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns a new employee as @employee' do
        get :new, {}, valid_session
        assigns(:employee).should be_a_new(Employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        get :new, {}, valid_session
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'POST create' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      describe 'with valid params' do
        it 'creates a new Employee' do
          EmployeesService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
          post :create, {:employee => employee_attributes}, valid_session
        end

        it 'assigns a newly created employee as @employee' do
          EmployeesService.any_instance.stub(:create_employee).and_return(new_employee)
          post :create, {:employee => employee_attributes}, valid_session
          assigns(:employee).should be_a(Employee)
        end

        it 'redirects to the created employee' do
          EmployeesService.any_instance.stub(:create_employee).and_return(create_employee)
          post :create, {:employee => employee_attributes}, valid_session
          response.should redirect_to(Employee.last)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved employee as @employee' do
          EmployeesService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
          Employee.any_instance.stub(:save).and_return(false)

          post :create, {:employee => {'name' => 'invalid value'}}, valid_session

          assigns(:employee).should be_a_new(Employee)
        end

        it "re-renders the 'new' template" do
          EmployeesService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
          post :create, {:employee => {'name' => 'invalid value'}}, valid_session
          response.should render_template('new')
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls EmployeesService' do
        EmployeesService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
        post :create, {:employee => employee_attributes}, valid_session
      end

      it 'assigns a newly created employee as @employee' do
        EmployeesService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
        post :create, {:employee => employee_attributes}, valid_session
        assigns(:employee).should be_a(Employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        expect {
          post :create, {:employee => employee_attributes}, valid_session
        }.not_to change(Employee, :count)
        assigns(:employee).should be_nil
      end
    end
  end
  
  describe 'GET index' do
    it 'calls get_all_employees with current_user and params' do
      my_user = stub_certification_user
      sign_in my_user
      @fake_employee_service = controller.load_employee_service(FakeService.new([]))
      params = {sort: 'name', direction: 'asc'}

      get :index, params

      @fake_employee_service.received_messages.should == [:get_all_employees]
      @fake_employee_service.received_params[0].should == my_user
      @fake_employee_service.received_params[1]['sort'].should == 'name'
      @fake_employee_service.received_params[1]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns @employees and @employees_count' do
        employee = new_employee
        @fake_employee_service = controller.load_employee_service(FakeService.new([employee]))

        get :index

        assigns(:employees).should eq([employee])
        assigns(:employee_count).should eq(1)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns employee as @employee' do
        employee = new_employee
        @fake_employee_service = controller.load_employee_service(FakeService.new([employee]))

        get :index

        assigns(:employees).should eq([employee])
        assigns(:employee_count).should eq(1)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign employee as @employee' do
          employee = new_employee
          @fake_employee_service = controller.load_employee_service(FakeService.new([employee]))

          get :index

          assigns(:employees).should be_nil
          assigns(:employee_count).should be_nil
        end
      end
    end
  end

  describe 'GET show' do
    context 'when employee user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns employee as @employee' do
        employee = create_employee(customer: @customer)
        get :show, {:id => employee.to_param}, valid_session
        assigns(:employee).should eq(employee)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns employee as @employee' do
        employee = create_employee(customer: @customer)
        get :show, {:id => employee.to_param}, valid_session
        assigns(:employee).should eq(employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create_employee(customer: @customer)
        get :show, {:id => employee.to_param}, valid_session
        assigns(:employee).should be_nil
      end
    end
  end
end