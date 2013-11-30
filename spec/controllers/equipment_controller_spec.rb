require 'spec_helper'

describe EquipmentController do
  let(:customer) { build(:customer) }
  let(:equipment) { build(:equipment) }
  let(:fake_equipment_service_that_returns_list) { Faker.new([equipment]) }

  describe 'GET index' do
    it 'calls get_all_equipment with current_user and params' do
      my_user = stub_equipment_user(customer)
      sign_in my_user
      fake_equipment_service = controller.load_equipment_service(Faker.new([]))
      fake_equipment_list_presenter = Faker.new([])
      EquipmentListPresenter.stub(:new).and_return(fake_equipment_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :index, params

      fake_equipment_service.received_messages.should == [:get_all_equipment]
      fake_equipment_service.received_params[0].should == my_user

      fake_equipment_list_presenter.received_message.should == :present
      fake_equipment_list_presenter.received_params[0]['sort'].should == 'name'
      fake_equipment_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
        controller.load_equipment_service(fake_equipment_service_that_returns_list)
      end

      it 'assigns equipment as @equipment' do
        get :index

        assigns(:equipments).map(&:model).should eq([equipment])
      end

      it 'assigns equipment_count' do
        get :index

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        get :index

        assigns(:report_title).should eq('All Equipment')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
        controller.load_equipment_service(fake_equipment_service_that_returns_list)
      end

      it 'assigns equipment as @equipment' do
        get :index

        assigns(:equipments).map(&:model).should eq([equipment])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign equipment as @equipment' do
          get :index

          assigns(:equipments).should be_nil
        end
      end
    end
  end

  describe 'GET expired' do

    let(:expired_equipment) { build(:expired_equipment, customer: customer) }

    it 'calls get_expired_equipment with current_user and params' do
      my_user = stub_equipment_user(customer)
      sign_in my_user
      fake_equipment_service = controller.load_equipment_service(Faker.new([]))
      fake_equipment_list_presenter = Faker.new([])
      EquipmentListPresenter.stub(:new).and_return(fake_equipment_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :expired, params

      fake_equipment_service.received_messages.should == [:get_expired_equipment]
      fake_equipment_service.received_params[0].should == my_user

      fake_equipment_list_presenter.received_message.should == :present
      fake_equipment_list_presenter.received_params[0]['sort'].should == 'name'
      fake_equipment_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
        controller.load_equipment_service(Faker.new([expired_equipment]))
      end

      it 'assigns equipment as @equipment' do
        get :expired

        assigns(:equipments).map(&:model).should eq([expired_equipment])
      end

      it 'assigns equipment_count' do
        get :expired

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        get :expired

        assigns(:report_title).should eq('Expired Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
        controller.load_equipment_service(Faker.new([expired_equipment]))
      end

      it 'assigns equipment as @equipment' do
        get :expired

        assigns(:equipments).map(&:model).should eq([expired_equipment])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET expired' do
        it 'does not assign equipment as @equipment' do
          get :expired

          assigns(:equipments).should be_nil
        end
      end
    end
  end

  describe 'GET expiring' do

    let(:expiring_equipment) { build(:expiring_equipment, customer: customer) }

    it 'calls get_expiring_equipment with current_user and params' do
      my_user = stub_equipment_user(customer)
      sign_in my_user
      fake_equipment_service = controller.load_equipment_service(Faker.new([]))
      fake_equipment_list_presenter = Faker.new([])
      EquipmentListPresenter.stub(:new).and_return(fake_equipment_list_presenter)

      params = {sort: 'name', direction: 'asc'}

      get :expiring, params

      fake_equipment_service.received_messages.should == [:get_expiring_equipment]
      fake_equipment_service.received_params[0].should == my_user

      fake_equipment_list_presenter.received_message.should == :present
      fake_equipment_list_presenter.received_params[0]['sort'].should == 'name'
      fake_equipment_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
        controller.load_equipment_service(Faker.new([expiring_equipment]))
      end

      it 'assigns equipment as @equipment' do
        get :expiring

        assigns(:equipments).map(&:model).should eq([expiring_equipment])
      end

      it 'assigns equipment_count' do
        get :expiring

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        get :expiring

        assigns(:report_title).should eq('Expiring Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
        controller.load_equipment_service(Faker.new([expiring_equipment]))
      end

      it 'assigns equipment as @equipment' do
        get :expiring

        assigns(:equipments).map(&:model).should eq([expiring_equipment])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET expiring' do
        it 'does not assign equipment as @equipment' do
          get :expiring

          assigns(:equipments).should be_nil
        end
      end
    end
  end

  describe 'GET noninspectable' do
    let(:noninspectable_equipment) { build(:noninspectable_equipment, customer: customer) }

    it 'calls get_noninspectable_equipment with current_user and params' do
      my_user = stub_equipment_user(customer)
      sign_in my_user
      fake_equipment_service = controller.load_equipment_service(Faker.new([]))
      fake_equipment_list_presenter = Faker.new([])
      EquipmentListPresenter.stub(:new).and_return(fake_equipment_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :noninspectable, params

      fake_equipment_service.received_messages.should == [:get_noninspectable_equipment]
      fake_equipment_service.received_params[0].should == my_user

      fake_equipment_list_presenter.received_message.should == :present
      fake_equipment_list_presenter.received_params[0]['sort'].should == 'name'
      fake_equipment_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
        controller.load_equipment_service(Faker.new([noninspectable_equipment]))
      end

      it 'assigns equipment as @equipment' do
        get :noninspectable

        assigns(:equipments).map(&:model).should eq([noninspectable_equipment])
      end

      it 'assigns equipment_count' do
        get :noninspectable

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        get :noninspectable

        assigns(:report_title).should eq('Non-Inspectable Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
        controller.load_equipment_service(Faker.new([noninspectable_equipment]))
      end

      it 'assigns equipment as @equipment' do
        get :noninspectable

        assigns(:equipments).map(&:model).should eq([noninspectable_equipment])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET noninspectable' do
        it 'does not assign equipment as @equipment' do
          get :noninspectable

          assigns(:equipments).should be_nil
        end
      end
    end
  end

  describe 'GET show' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'assigns equipment as @equipment' do
        equipment = create(:equipment, customer: customer)

        get :show, {:id => equipment.to_param}, {}

        assigns(:model).should eq(equipment)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do

        equipment = create(:equipment, customer: customer)

        get :show, {:id => equipment.to_param}, {}

        assigns(:model).should eq(equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        equipment = create(:equipment, customer: customer)

        get :show, {:id => equipment.to_param}, {}

        assigns(:model).should be_nil
      end
    end
  end

  describe 'GET new' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'assigns a new equipment as @equipment' do

        get :new, {}, {}

        assigns(:equipment).should be_a_new(Equipment)
      end

      it 'assigns @intervals' do
        equipment = create(:equipment, customer: customer)

        get :new, {:id => equipment.to_param}, {}

        assigns(:intervals).should eq(Interval.all.to_a)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns a new equipment as @equipment' do
        get :new, {}, {}

        assigns(:equipment).should be_a_new(Equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        get :new, {}, {}

        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'GET edit' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'assigns the requested equipment as @equipment' do
        equipment = create(:equipment, customer: customer)

        get :edit, {:id => equipment.to_param}, {}

        assigns(:equipment).should eq(equipment)
      end

      it 'assigns @intervals' do
        equipment = create(:equipment, customer: customer)

        get :edit, {:id => equipment.to_param}, {}

        assigns(:intervals).should eq(Interval.all.to_a)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns the requested equipment as @equipment' do
        equipment = create(:equipment, customer: customer)

        get :edit, {:id => equipment.to_param}, {}

        assigns(:equipment).should eq(equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        equipment = create(:equipment, customer: customer)

        get :edit, {:id => equipment.to_param}, {}

        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'POST create' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      describe 'with valid params' do
        it 'creates a new equipment' do
          fake_equipment_service = Faker.new(build(:equipment))
          controller.load_equipment_service(fake_equipment_service)

          post :create, {:equipment => equipment_attributes}, {}

          fake_equipment_service.received_message.should == :create_equipment
        end

        it 'assigns a newly created equipment as @equipment' do
          controller.load_equipment_service(Faker.new(build(:equipment)))

          post :create, {:equipment => equipment_attributes}, {}

          assigns(:equipment).should be_a(Equipment)
        end

        it 'redirects to the created equipment' do
          equipment = create(:equipment)
          controller.load_equipment_service(Faker.new(equipment))

          post :create, {:equipment => equipment_attributes}, {}

          response.should redirect_to(Equipment.last)
          flash[:notice].should == 'Equipment was successfully created.'
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved equipment as @equipment' do
          fake_equipment_service = Faker.new(build(:equipment))
          controller.load_equipment_service(fake_equipment_service)

          post :create, {:equipment => {'name' => 'invalid value'}}, {}

          assigns(:equipment).should be_a_new(Equipment)
          fake_equipment_service.received_message.should == :create_equipment
        end

        it "re-renders the 'new' template" do
          controller.load_equipment_service(Faker.new(build(:equipment)))

          post :create, {:equipment => {'name' => 'invalid value'}}, {}

          response.should render_template('new')
        end

        it 'assigns @intervals' do
          controller.load_equipment_service(Faker.new(build(:equipment)))

          post :create, {:equipment => {'name' => 'invalid value'}}, {}

          assigns(:intervals).should eq(Interval.all.to_a)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls EquipmentService' do
        fake_equipment_service = Faker.new(build(:equipment))
        controller.load_equipment_service(fake_equipment_service)

        post :create, {:equipment => equipment_attributes}, {}

        fake_equipment_service.received_message.should == :create_equipment
      end

      it 'assigns a newly created equipment as @equipment' do
        controller.load_equipment_service(Faker.new(build(:equipment)))

        post :create, {:equipment => equipment_attributes}, {}

        assigns(:equipment).should be_a(Equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        expect {
          post :create, {:equipment => equipment_attributes}, {}
        }.not_to change(Equipment, :count)
        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'PUT update' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested equipment' do
          equipment = create(:equipment, customer: customer)
          fake_equipment_service = Faker.new(true)
          controller.load_equipment_service(fake_equipment_service)

          put :update, {:id => equipment.to_param, :equipment =>
            {
              'name' => 'Box',
              'serial_number' => 'newSN',
              'inspection_interval' => 'Annually',
              'last_inspection_date' => '01/01/2001',
              'comments' => 'some new notes'
            }
          }, {}

          fake_equipment_service.received_message.should == :update_equipment
          fake_equipment_service.received_params[0].should == equipment
        end

        it 'assigns the requested equipment as @equipment' do
          controller.load_equipment_service(Faker.new(true))
          equipment = create(:equipment, customer: customer)

          put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, {}

          assigns(:equipment).should eq(equipment)
        end

        it 'redirects to the equipment' do
          controller.load_equipment_service(Faker.new(true))
          equipment = create(:equipment, customer: customer)

          put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, {}

          response.should redirect_to(equipment)
          flash[:notice].should == 'Equipment was successfully updated.'
        end
      end

      describe 'with invalid params' do
        it 'assigns the equipment as @equipment' do
          controller.load_equipment_service(Faker.new(false))
          equipment = create(:equipment, customer: customer)

          put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, {}

          assigns(:equipment).should eq(equipment)
        end

        it "re-renders the 'edit' template" do
          equipment = create(:equipment, customer: customer)
          controller.load_equipment_service(Faker.new(false))

          put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns @intervals' do
          equipment = create(:equipment, customer: customer)
          controller.load_equipment_service(Faker.new(false))

          put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, {}

          assigns(:intervals).should eq(Interval.all.to_a)
        end
      end

    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'updates the requested equipment' do
        equipment = create(:equipment, customer: customer)
        fake_equipment_service = Faker.new(true)
        controller.load_equipment_service(fake_equipment_service)
        params = {
          'name' => 'Box',
          'serial_number' => 'newSN',
          'inspection_interval' => 'Annually',
          'last_inspection_date' => '01/01/2001',
          'comments' => 'some new notes'
        }

        put :update, {:id => equipment.to_param, :equipment => params}, {}

        fake_equipment_service.received_message.should == :update_equipment
        fake_equipment_service.received_params[0].should == equipment
        fake_equipment_service.received_params[1].should == params
      end

      it 'assigns the requested equipment as @equipment' do
        equipment = create(:equipment, customer: customer)
        controller.load_equipment_service(Faker.new(equipment))

        put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, {}

        assigns(:equipment).should eq(equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        equipment = create(:equipment, customer: customer)

        put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, {}

        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'calls EquipmentService' do
        equipment = create(:equipment, customer: customer)
        fake_equipment_service = Faker.new(true)
        controller.load_equipment_service(fake_equipment_service)

        delete :destroy, {:id => equipment.to_param}, {}

        fake_equipment_service.received_message.should == :delete_equipment
        fake_equipment_service.received_params[0].should == equipment
      end

      it 'redirects to the equipment list' do
        equipment = create(:equipment, customer: customer)
        controller.load_equipment_service(Faker.new(true))

        delete :destroy, {:id => equipment.to_param}, {}

        response.should redirect_to(equipment_index_url)
        flash[:notice].should == 'Equipment was successfully deleted.'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls EquipmentService' do
        equipment = create(:equipment, customer: customer)
        fake_equipment_service = Faker.new(true)
        controller.load_equipment_service(fake_equipment_service)

        delete :destroy, {:id => equipment.to_param}, {}

        fake_equipment_service.received_message.should == :delete_equipment
        fake_equipment_service.received_params[0].should == equipment
      end
    end
  end

  describe 'GET search' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'calls get_all_equipment with current_user and params' do
        my_user = stub_equipment_user(customer)
        sign_in my_user
        fake_equipment_service = controller.load_equipment_service(Faker.new([]))
        params = {sort: 'name', direction: 'asc'}
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))
        fake_equipment_list_presenter = Faker.new([])
        EquipmentListPresenter.stub(:new).and_return(fake_equipment_list_presenter)

        get :search, params

        fake_equipment_service.received_message.should == :search_equipment
        fake_equipment_service.received_params[0].should == my_user

        fake_equipment_list_presenter.received_message.should == :present
        fake_equipment_list_presenter.received_params[0]['sort'].should == 'name'
        fake_equipment_list_presenter.received_params[0]['direction'].should == 'asc'
      end

      it 'assigns equipment as @equipment' do
        equipment = build(:equipment, customer: customer)
        fake_equipment_service = Faker.new([equipment])
        controller.load_equipment_service(fake_equipment_service)
        EmployeeListPresenter.stub(:new).and_return(Faker.new([EquipmentPresenter.new(equipment)]))

        get :search

        assigns(:equipments).map(&:model).should eq([equipment])
        fake_equipment_service.received_message.should == :search_equipment
      end

      it 'assigns equipment_count' do
        controller.load_equipment_service(Faker.new([build(:equipment)]))

        get :search

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        controller.load_equipment_service(Faker.new([]))

        get :search

        assigns(:report_title).should eq('Search Equipment')
      end

      it 'assigns sorted locations' do
        location = build(:location)
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
        controller.load_location_service(Faker.new([location]))
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))

        get :search

        assigns(:locations).should == [location]
        fake_location_list_presenter.received_message.should == :sort
      end

      it 'assigns employees' do
        employee = build(:employee)
        controller.load_employee_service(Faker.new([employee]))
        fake_equipment_list_presenter = Faker.new([EmployeePresenter.new(employee)])
        EmployeeListPresenter.stub(:new).and_return(fake_equipment_list_presenter)

        get :search

        assigns(:employees).map(&:model).should == [employee]
        fake_equipment_list_presenter.received_message.should == :present
        fake_equipment_list_presenter.received_params[0].should == {sort: :sort_key}
      end
    end
  end

  describe 'GET ajax_assignee' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'should return sorted locations when assignee is Location' do
        location = create(:location, name: 'Oz')
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
        controller.load_location_service(Faker.new([location]))
        fake_employee_service = controller.load_location_service(Faker.new([location]))

        get :ajax_assignee, {assignee: 'Location'}

        fake_employee_service.received_message.should == :get_all_locations
        fake_location_list_presenter.received_message.should == :sort
        json = JSON.parse(response.body)
        json.should == [
          [location.id, 'Oz']
        ]
      end

      it 'should return sorted employees when assignee is Employee' do
        employee = create(:employee, first_name: 'Wendy', last_name: 'Wizard')
        fake_employee_service = controller.load_employee_service(Faker.new([employee]))
        fake_employee_list_presenter = Faker.new([EmployeePresenter.new(employee)])
        EmployeeListPresenter.stub(:new).and_return(fake_employee_list_presenter)

        get :ajax_assignee, {assignee: 'Employee'}

        fake_employee_service.received_message.should == :get_all_employees
        fake_employee_list_presenter.received_message.should == :sort
        fake_employee_list_presenter.received_params[0][:sort].should == 'sort_key'
        fake_employee_list_presenter.received_params[0][:direction].should == 'asc'
        json = JSON.parse(response.body)
        json.should == [
          [employee.id, 'Wizard, Wendy']
        ]
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'should redirect, I suppose' do
        get :ajax_assignee, {assignee: 'Location'}
        response.body.should eq("<html><body>You are being <a href=\"http://test.host/\">redirected</a>.</body></html>")
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'should return locations when assignee is Location' do
        location = build(:location, name: 'Oz')
        fake_location_service = Faker.new([location])
        controller.load_location_service(fake_location_service)

        get :ajax_assignee, {assignee: 'Location'}

        JSON.parse(response.body).should == [[location.id, 'Oz']]
        fake_location_service.received_message.should == :get_all_locations
      end
    end
  end

  describe 'GET ajax_equipment_name' do
    context 'when equipment user' do
      let (:current_user) { stub_equipment_user(customer) }
      before do
        sign_in current_user
      end

      it 'should call equipment_service to retrieve names' do
        fake_employee_service = controller.load_equipment_service(Faker.new(['cat']))

        get :ajax_equipment_name, {term: 'cat'}

        json = JSON.parse(response.body)
        json.should == ['cat']
        fake_employee_service.received_message.should == :get_equipment_names
        fake_employee_service.received_params[0].should == current_user
        fake_employee_service.received_params[1].should == 'cat'
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'should redirect, I suppose' do
        get :ajax_equipment_name, {term: 'cat'}
        response.body.should eq("<html><body>You are being <a href=\"http://test.host/\">redirected</a>.</body></html>")
      end
    end

    context 'when admin user' do
      let (:current_user) { stub_admin(customer) }
      before do
        sign_in current_user
      end

      it 'should call equipment_service to retrieve names' do
        fake_employee_service = controller.load_equipment_service(Faker.new(['cat']))

        get :ajax_equipment_name, {term: 'cat'}

        json = JSON.parse(response.body)
        json.should == ['cat']
        fake_employee_service.received_message.should == :get_equipment_names
        fake_employee_service.received_params[0].should == current_user
        fake_employee_service.received_params[1].should == 'cat'
      end
    end
  end

  def equipment_attributes
    {
      name: 'Meter',
      serial_number: '782-888-DKHE',
      last_inspection_date: Date.new(2000, 1, 1),
      inspection_interval: Interval::ONE_YEAR.text
    }
  end
end

