require 'spec_helper'

describe EmployeesController do
  let(:customer) {create(:customer)}

  describe 'GET new' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns a new employee as @employee' do
        get :new, {}, {}
        assigns(:employee).should be_a_new(Employee)
      end

      it 'assigns locations' do
        location = build(:location)
        LocationService.any_instance.stub(:get_all_locations).and_return([location])

        get :new

        assigns(:locations).should == [location]
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
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
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'creates a new Employee' do
          EmployeeService.any_instance.should_receive(:create_employee).once.and_return(build(:employee))
          post :create, {:employee => employee_attributes}, {}
        end

        it 'assigns a newly created employee as @employee' do
          EmployeeService.any_instance.stub(:create_employee).and_return(build(:employee))
          post :create, {:employee => employee_attributes}, {}
          assigns(:employee).should be_a(Employee)
        end

        it 'redirects to the created employee' do
          EmployeeService.any_instance.stub(:create_employee).and_return(create(:employee))
          post :create, {:employee => employee_attributes}, {}
          response.should redirect_to(Employee.last)
          flash[:notice].should == 'Employee was successfully created.'
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved employee as @employee' do
          EmployeeService.any_instance.should_receive(:create_employee).once.and_return(build(:employee))
          Employee.any_instance.stub(:save).and_return(false)

          post :create, {:employee => {'name' => 'invalid value'}}, {}

          assigns(:employee).should be_a_new(Employee)
        end

        it "re-renders the 'new' template" do
          EmployeeService.any_instance.should_receive(:create_employee).once.and_return(build(:employee))
          post :create, {:employee => {'name' => 'invalid value'}}, {}
          response.should render_template('new')
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls EmployeesService' do
        EmployeeService.any_instance.should_receive(:create_employee).once.and_return(build(:employee))
        post :create, {:employee => employee_attributes}, {}
      end

      it 'assigns a newly created employee as @employee' do
        EmployeeService.any_instance.should_receive(:create_employee).once.and_return(build(:employee))
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
    it 'calls get_all_employees with current_user and params' do
      my_user = stub_certification_user(customer)
      sign_in my_user
      fake_employee_service = controller.load_employee_service(Faker.new([]))
      fake_employee_list_presenter = Faker.new([])
      #noinspection RubyArgCount
      EmployeeListPresenter.stub(:new).and_return(fake_employee_list_presenter)

      get :index, {sort: 'name', direction: 'asc'}

      fake_employee_service.received_message.should == :get_all_employees
      fake_employee_service.received_params[0].should == my_user

      fake_employee_list_presenter.received_message.should == :present
      fake_employee_list_presenter.received_params[0]['sort'].should == 'name'
      fake_employee_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns @employees and @employee_count' do
        employee = build(:employee)
        controller.load_employee_service(Faker.new([employee]))

        get :index

        assigns(:employees).map(&:model).should eq([employee])
        assigns(:employee_count).should eq(1)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns employee as @employee' do
        employee = build(:employee)
        controller.load_employee_service(Faker.new([employee]))

        get :index

        assigns(:employees).map(&:model).should eq([employee])
        assigns(:employee_count).should eq(1)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign employee as @employee' do
          employee = build(:employee)
          controller.load_employee_service(Faker.new([employee]))

          get :index

          assigns(:employees).should be_nil
          assigns(:employee_count).should be_nil
        end
      end
    end
  end

  describe 'GET show' do
    let(:employee) { create(:employee, customer: customer) }
    let(:certification_service) { double('certification_service') }
    let(:certification) { create(:certification, employee: employee, customer: employee.customer) }
    let(:certifications) { [certification] }

    before do
      controller.load_certification_service(certification_service)
      certification_service.stub(:get_all_certifications_for_employee).and_return(certifications)
    end
    
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns employee as @employee' do
        get :show, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end

      it 'assigns certifications as @certifications' do
        get :show, { id: employee.to_param }, {}
        assigns(:certifications).map(&:model).should == certifications
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns employee as @employee' do
        get :show, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end

      it 'assigns certifications as @certifications' do
        get :show, { id: employee.to_param }, {}
        assigns(:certifications).map(&:model).should == certifications
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create(:employee, customer: customer)
        get :show, {:id => employee.to_param}, {}
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'GET edit' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'assigns the requested employee as @employee' do
        employee = create(:employee, customer: customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end

      it 'assigns locations' do
        location = build(:location)
        controller.load_location_service(Faker.new([location]))
        employee = create(:employee, customer: customer)

        get :edit, {:id => employee.to_param}, {}

        assigns(:locations).should == [location]
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns the requested employee as @employee' do
        employee = create(:employee, customer: customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should eq(employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create(:employee, customer: customer)
        get :edit, {:id => employee.to_param}, {}
        assigns(:employee).should be_nil
      end
    end
  end

  describe 'PUT update' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested employee' do
          employee = create(:employee, customer: customer)
          fake_employee_service = controller.load_employee_service(Faker.new([]))

          put :update, {:id => employee.to_param, :employee =>
            {
              'first_name' => 'Susie',
              'last_name' => 'Sampson',
              'employee_number' => 'newEmpNum',
              'location_id' => 1,
            }
          }, {}

          fake_employee_service.received_messages.should == [:update_employee]
        end

        it 'assigns the requested employee as @employee' do
          employee = create(:employee, customer: customer)
          fake_employee_service = controller.load_employee_service(Faker.new(true))

          put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

          assigns(:employee).should eq(employee)
          fake_employee_service.received_messages.should == [:update_employee]
        end

        it 'redirects to the employee' do
          controller.load_employee_service(Faker.new(true))
          employee = create(:employee, customer: customer)

          put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

          response.should redirect_to(employee)
          flash[:notice].should == 'Employee was successfully updated.'
        end
      end

      describe 'with invalid params' do
        it 'assigns the employee as @employee' do
          employee = create(:employee, customer: customer)
          controller.load_employee_service(Faker.new(false))

          put :update, {:id => employee.to_param, :employee => {'name' => 'invalid value'}}, {}

          assigns(:employee).should eq(employee)
        end

        it "re-renders the 'edit' template" do
          employee = create(:employee, customer: customer)
          controller.load_employee_service(Faker.new(false))

          put :update, {:id => employee.to_param, :employee => {'name' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns locations' do
          controller.load_employee_service(Faker.new(false))
          location = build(:location)
          controller.load_location_service(Faker.new([location]))
          employee = create(:employee, customer: customer)

          put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

          assigns(:locations).should == [location]
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'updates the requested employee' do
        employee = create(:employee, customer: customer)
        fake_employee_service = controller.load_employee_service(Faker.new(true))

        put :update, {:id => employee.to_param, :employee =>
          {
            'first_name' => 'Susie',
            'last_name' => 'Sampson',
            'employee_number' => 'newEmpNum',
            'location_id' => 1
          }
        }, {}

        fake_employee_service.received_messages.should == [:update_employee]
      end

      it 'assigns the requested employee as @employee' do
        employee = create(:employee, customer: customer)
        controller.load_employee_service(Faker.new(true))

        put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

        assigns(:employee).should eq(employee)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign employee as @employee' do
        employee = create(:employee, customer: customer)

        put :update, {:id => employee.to_param, :employee => employee_attributes}, {}

        assigns(:employee).should be_nil
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user(customer)
      end

      it 'calls EmployeesService' do
        employee = create(:employee, customer: customer)
        fake_employee_service = controller.load_employee_service(Faker.new(true))

        delete :destroy, {:id => employee.to_param}, {}

        fake_employee_service.received_message.should == :delete_employee
      end

      it 'redirects to the employee list' do
        employee = create(:employee, customer: customer)
        controller.load_employee_service(Faker.new(true))

        delete :destroy, {:id => employee.to_param}, {}

        response.should redirect_to(employees_url)
        flash[:notice].should == 'Employee was successfully deleted.'
      end

      it 'gives error message when equipment exists' do
        employee = create(:employee, customer: customer)
        controller.load_employee_service(Faker.new(:equipment_exists))

        delete :destroy, {:id => employee.to_param}, {}

        response.should redirect_to(employee_url)
        flash[:notice].should == 'Employee has equipment assigned, you must remove them before deleting the employee. Or Deactivate the employee instead.'
      end

      it 'gives error message when certifications exists' do
        employee = create(:employee, customer: customer)
        controller.load_employee_service(Faker.new(:certification_exists))

        delete :destroy, {:id => employee.to_param}, {}

        response.should redirect_to(employee_url)
        flash[:notice].should == 'Employee has certifications, you must remove them before deleting the employee. Or Deactivate the employee instead.'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls EmployeesService' do
        employee = create(:employee, customer: customer)
        controller.load_employee_service(Faker.new(true))

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

def a_presentable_employee_for(employee)
  EmployeePresenter.new(employee)
end

