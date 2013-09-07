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
        get :new, {}, {}
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
        get :new, {}, {}
        assigns(:employee).should be_a_new(Employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        get :new, {}, {}
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
          EmployeeService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
          post :create, {:employee => employee_attributes}, {}
        end

        it 'assigns a newly created employee as @employee' do
          EmployeeService.any_instance.stub(:create_employee).and_return(new_employee)
          post :create, {:employee => employee_attributes}, {}
          assigns(:employee).should be_a(Employee)
        end

        it 'redirects to the created employee' do
          EmployeeService.any_instance.stub(:create_employee).and_return(create_employee)
          post :create, {:employee => employee_attributes}, {}
          response.should redirect_to(Employee.last)
          flash[:notice].should == 'Employee was successfully created.'
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved employee as @employee' do
          EmployeeService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
          Employee.any_instance.stub(:save).and_return(false)

          post :create, {:employee => {'name' => 'invalid value'}}, {}

          assigns(:employee).should be_a_new(Employee)
        end

        it "re-renders the 'new' template" do
          EmployeeService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
          post :create, {:employee => {'name' => 'invalid value'}}, {}
          response.should render_template('new')
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls EmployeesService' do
        EmployeeService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
        post :create, {:employee => employee_attributes}, {}
      end

      it 'assigns a newly created employee as @employee' do
        EmployeeService.any_instance.should_receive(:create_employee).once.and_return(new_employee)
        post :create, {:employee => employee_attributes}, {}
        assigns(:employee).should be_a(Employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        expect {
          post :create, {:employee => employee_attributes}, {}
        }.not_to change(Employee, :count)
        assigns(:employee).should be_nil
      end
    end
  end
  
  describe 'GET index' do
    it 'calls get_employee_list with current_user and params' do
      my_user = stub_certification_user
      sign_in my_user
      @fake_employee_service = controller.load_employee_service(FakeService.new([]))
      params = {sort: 'name', direction: 'asc'}

      get :index, params

      @fake_employee_service.received_messages.should == [:get_employee_list]
      @fake_employee_service.received_params[0].should == my_user
      @fake_employee_service.received_params[1]['sort'].should == 'name'
      @fake_employee_service.received_params[1]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns @employees and @employee_count' do
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
    let(:employee) { create_employee(customer: @customer) }
    let(:certification_service) { double('certification_service') }
    let(:certification) { create(:certification, employee: employee) }
    let(:certifications) { [certification] }

    before do
      controller.load_certification_service(certification_service)
      certification_service.stub(:get_all_certifications_for).and_return(certifications)
    end
    
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns employee as @employee' do
        get :show, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end

      it 'assigns certifications as @certifications' do
        get :show, { id: employee.to_param }, {}
        assigns(:certifications).should == certifications
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns employee as @employee' do
        get :show, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end

      it 'assigns certifications as @certifications' do
        get :show, { id: employee.to_param }, {}
        assigns(:certifications).should == certifications
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create_employee(customer: @customer)
        get :show, {:id => employee.to_param}, {}
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'GET edit' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns the requested employee as @employee' do
        employee = create_employee(customer: @customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end

      it 'assigns locations' do
        location = new_location
        @fake_location_service = controller.load_location_service(FakeService.new([location]))
        employee = create_employee(customer: @customer)

        get :edit, {:id => employee.to_param}, {}

        assigns(:locations).should == [location]
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns the requested employee as @employee' do
        employee = create_employee(customer: @customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create_employee(customer: @customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'PUT update' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      describe 'with valid params' do
        it 'updates the requested employee' do
          employee = create_employee(customer: @customer)
          @fake_employee_service = controller.load_employee_service(FakeService.new([]))

          put :update, {:id => employee.to_param, :employee =>
            {
              'first_name' => 'Susie',
              'last_name' => 'Sampson',
              'employee_number' => 'newEmpNum',
              'location_id' => 1,
            }
          }, {}

          @fake_employee_service.received_messages.should == [:update_employee]
        end

        it 'assigns the requested employee as @employee' do
          employee = create_employee(customer: @customer)
          @fake_employee_service = controller.load_employee_service(FakeService.new(true))

          put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

          assigns(:employee).should eq(employee)
          @fake_employee_service.received_messages.should == [:update_employee]
        end

        it 'redirects to the employee' do
          @fake_employee_service = controller.load_employee_service(FakeService.new(true))
          employee = create_employee(customer: @customer)

          put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

          response.should redirect_to(employee)
          flash[:notice].should == 'Employee was successfully updated.'
        end
      end

      describe 'with invalid params' do
        it 'assigns the employee as @employee' do
          employee = create_employee(customer: @customer)
          @fake_employee_service = controller.load_employee_service(FakeService.new(false))

          put :update, {:id => employee.to_param, :employee => {'name' => 'invalid value'}}, {}

          assigns(:employee).should eq(employee)
        end

        it "re-renders the 'edit' template" do
          employee = create_employee(customer: @customer)
          @fake_employee_service = controller.load_employee_service(FakeService.new(false))

          put :update, {:id => employee.to_param, :employee => {'name' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns locations' do
          @fake_employee_service = controller.load_employee_service(FakeService.new(false))
          location = new_location
          @fake_location_service = controller.load_location_service(FakeService.new([location]))
          employee = create_employee(customer: @customer)

          put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

          assigns(:locations).should == [location]
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'updates the requested employee' do
        employee = create_employee(customer: @customer)
        @fake_employee_service = controller.load_employee_service(FakeService.new(true))

        put :update, {:id => employee.to_param, :employee =>
          {
            'first_name' => 'Susie',
            'last_name' => 'Sampson',
            'employee_number' => 'newEmpNum',
            'location_id' => 1
          }
        }, {}

        @fake_employee_service.received_messages.should == [:update_employee]
      end

      it 'assigns the requested employee as @employee' do
        employee = create_employee(customer: @customer)
        @fake_employee_service = controller.load_employee_service(FakeService.new(true))

        put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

        assigns(:employee).should eq(employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create_employee(customer: @customer)

        put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

        assigns(:employee).should be_nil
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'calls EmployeesService' do
        employee = create_employee(customer: @customer)
        @fake_employee_service = controller.load_employee_service(FakeService.new(true))

        delete :destroy, {:id => employee.to_param}, {}

        @fake_employee_service.received_message.should == :delete_employee
      end

      it 'redirects to the employee list' do
        employee = create_employee(customer: @customer)
        @fake_employee_service = controller.load_employee_service(FakeService.new(true))

        delete :destroy, {:id => employee.to_param}, {}

        response.should redirect_to(employees_url)
        flash[:notice].should == 'Employee was successfully deleted.'
      end

      it 'gives error message when equipment exists' do
        employee = create_employee(customer: @customer)
        @fake_employee_service = controller.load_employee_service(FakeService.new(:equipment_exists))

        delete :destroy, {:id => employee.to_param}, {}

        response.should redirect_to(employee_url)
        flash[:notice].should == 'Employee has equipment assigned, you must remove them before deleting the employee. Or Deactivate the employee instead.'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls EmployeesService' do
        employee = create_employee(customer: @customer)
        @fake_employee_service = controller.load_employee_service(FakeService.new(true))

        delete :destroy, {:id => employee.to_param}, {}
      end
    end
  end

  def employee_attributes
    {
      first_name: 'John',
      last_name: 'Smith',
      employee_number: '876ABC'
    }
  end
end