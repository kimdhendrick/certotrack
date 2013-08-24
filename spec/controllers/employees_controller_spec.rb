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
end