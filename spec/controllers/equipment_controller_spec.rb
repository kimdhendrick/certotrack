require 'spec_helper'

describe EquipmentController do
  let(:customer) { build(:customer) }

  describe 'GET index' do
    it 'calls get_all_equipment with current_user and params' do
      my_user = stub_equipment_user(customer)
      sign_in my_user
      fake_equipment_service = controller.load_equipment_service(Faker.new([]))
      fake_equipment_list_presenter = Faker.new([])
      #noinspection RubyArgCount
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
      end

      it 'assigns equipment as @equipment' do
        equipment = build(:equipment)
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

        get :index

        assigns(:equipments).map(&:model).should eq([equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([build(:equipment)])

        get :index

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([build(:equipment)])

        get :index

        assigns(:report_title).should eq('All Equipment')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        equipment = build(:equipment)
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

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
          equipment = build(:equipment)
          EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

          get :index

          assigns(:equipments).should be_nil
        end
      end
    end
  end

  describe 'GET expired' do
    it 'calls get_expired_equipment with current_user and params' do
      my_user = stub_equipment_user(customer)
      sign_in my_user
      fake_equipment_service = controller.load_equipment_service(Faker.new([]))
      fake_equipment_list_presenter = Faker.new([])
      #noinspection RubyArgCount
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
      end

      it 'assigns equipment as @equipment' do
        expired_equipment = build(:expired_equipment, customer: customer)

        EquipmentService.any_instance.stub(:get_expired_equipment).and_return([expired_equipment])

        get :expired

        assigns(:equipments).map(&:model).should eq([expired_equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:get_expired_equipment).and_return([build(:equipment)])

        get :expired

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_expired_equipment).and_return([build(:equipment)])

        get :expired

        assigns(:report_title).should eq('Expired Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        expired_equipment = build(:expired_equipment, customer: customer)
        EquipmentService.any_instance.stub(:get_expired_equipment).and_return([expired_equipment])

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
          equipment = build(:equipment)
          EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

          get :expired

          assigns(:equipments).should be_nil
        end
      end
    end
  end

  describe 'GET expiring' do
    it 'calls get_expiring_equipment with current_user and params' do
      my_user = stub_equipment_user(customer)
      sign_in my_user
      fake_equipment_service = controller.load_equipment_service(Faker.new([]))
      fake_equipment_list_presenter = Faker.new([])
      #noinspection RubyArgCount
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
      end

      it 'assigns equipment as @equipment' do
        expiring_equipment = build(:expiring_equipment, customer: customer)

        EquipmentService.any_instance.stub(:get_expiring_equipment).and_return([expiring_equipment])

        get :expiring

        assigns(:equipments).map(&:model).should eq([expiring_equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:get_expiring_equipment).and_return([build(:equipment)])

        get :expiring

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_expiring_equipment).and_return([build(:equipment)])

        get :expiring

        assigns(:report_title).should eq('Expiring Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        expiring_equipment = build(:expiring_equipment, customer: customer)
        EquipmentService.any_instance.stub(:get_expiring_equipment).and_return([expiring_equipment])

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
          equipment = build(:equipment)
          EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

          get :expiring

          assigns(:equipments).should be_nil
        end
      end
    end
  end

  describe 'GET noninspectable' do
    it 'calls get_noninspectable_equipment with current_user and params' do
      my_user = stub_equipment_user(customer)
      sign_in my_user
      fake_equipment_service = controller.load_equipment_service(Faker.new([]))
      fake_equipment_list_presenter = Faker.new([])
      #noinspection RubyArgCount
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
      end

      it 'assigns equipment as @equipment' do
        noninspectable_equipment = build(:noninspectable_equipment, customer: customer)

        EquipmentService.any_instance.stub(:get_noninspectable_equipment).and_return([noninspectable_equipment])

        get :noninspectable

        assigns(:equipments).map(&:model).should eq([noninspectable_equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:get_noninspectable_equipment).and_return([build(:equipment)])

        get :noninspectable

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_noninspectable_equipment).and_return([build(:equipment)])

        get :noninspectable

        assigns(:report_title).should eq('Non-Inspectable Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        noninspectable_equipment = build(:noninspectable_equipment, customer: customer)
        EquipmentService.any_instance.stub(:get_noninspectable_equipment).and_return([noninspectable_equipment])

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
          equipment = build(:equipment)
          EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

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
        assigns(:equipment).should eq(equipment)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        equipment = create(:equipment, customer: customer)
        get :show, {:id => equipment.to_param}, {}
        assigns(:equipment).should eq(equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        equipment = create(:equipment, customer: customer)
        get :show, {:id => equipment.to_param}, {}
        assigns(:equipment).should be_nil
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
        it 'creates a new Equipment' do
          EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(build(:equipment))
          post :create, {:equipment => equipment_attributes}, {}
        end

        it 'assigns a newly created equipment as @equipment' do
          EquipmentService.any_instance.stub(:create_equipment).and_return(build(:equipment))
          post :create, {:equipment => equipment_attributes}, {}
          assigns(:equipment).should be_a(Equipment)
        end

        it 'redirects to the created equipment' do
          EquipmentService.any_instance.stub(:create_equipment).and_return(create(:equipment))

          post :create, {:equipment => equipment_attributes}, {}

          response.should redirect_to(Equipment.last)
          flash[:notice].should == 'Equipment was successfully created.'
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved equipment as @equipment' do
          EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(build(:equipment))
          Equipment.any_instance.stub(:save).and_return(false)

          post :create, {:equipment => {'name' => 'invalid value'}}, {}

          assigns(:equipment).should be_a_new(Equipment)
        end

        it "re-renders the 'new' template" do
          EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(build(:equipment))
          post :create, {:equipment => {'name' => 'invalid value'}}, {}
          response.should render_template('new')
        end

        it 'assigns @intervals' do
          EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(build(:equipment))
          Equipment.any_instance.stub(:save).and_return(false)
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
        EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(build(:equipment))
        post :create, {:equipment => equipment_attributes}, {}
      end

      it 'assigns a newly created equipment as @equipment' do
        EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(build(:equipment))
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
          EquipmentService.any_instance.should_receive(:update_equipment).once

          put :update, {:id => equipment.to_param, :equipment =>
            {
              'name' => 'Box',
              'serial_number' => 'newSN',
              'inspection_interval' => 'Annually',
              'last_inspection_date' => '01/01/2001',
              'comments' => 'some new notes'
            }
          }, {}
        end

        it 'assigns the requested equipment as @equipment' do
          EquipmentService.any_instance.stub(:update_equipment).and_return(true)
          equipment = create(:equipment, customer: customer)
          put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, {}
          assigns(:equipment).should eq(equipment)
        end

        it 'redirects to the equipment' do
          EquipmentService.any_instance.stub(:update_equipment).and_return(true)
          equipment = create(:equipment, customer: customer)

          put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, {}

          response.should redirect_to(equipment)
          flash[:notice].should == 'Equipment was successfully updated.'
        end
      end

      describe 'with invalid params' do
        it 'assigns the equipment as @equipment' do
          equipment = create(:equipment, customer: customer)
          EquipmentService.any_instance.stub(:update_equipment).and_return(false)
          put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, {}
          assigns(:equipment).should eq(equipment)
        end

        it "re-renders the 'edit' template" do
          equipment = create(:equipment, customer: customer)
          EquipmentService.any_instance.stub(:update_equipment).and_return(false)
          put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, {}
          response.should render_template('edit')
        end

        it 'assigns @intervals' do
          equipment = create(:equipment, customer: customer)
          EquipmentService.any_instance.stub(:update_equipment).and_return(false)
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
        EquipmentService.any_instance.should_receive(:update_equipment).once

        put :update, {:id => equipment.to_param, :equipment =>
          {
            'name' => 'Box',
            'serial_number' => 'newSN',
            'inspection_interval' => 'Annually',
            'last_inspection_date' => '01/01/2001',
            'comments' => 'some new notes'
          }
        }, {}
      end

      it 'assigns the requested equipment as @equipment' do
        equipment = create(:equipment, customer: customer)
        EquipmentService.any_instance.stub(:update_equipment).and_return(equipment)
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
        EquipmentService.any_instance.should_receive(:delete_equipment).once

        delete :destroy, {:id => equipment.to_param}, {}
      end

      it 'redirects to the equipment list' do
        equipment = create(:equipment, customer: customer)
        EquipmentService.any_instance.should_receive(:delete_equipment).once

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
        EquipmentService.any_instance.should_receive(:delete_equipment).once

        delete :destroy, {:id => equipment.to_param}, {}
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
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))
        fake_equipment_list_presenter = Faker.new([])
        #noinspection RubyArgCount
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
        EquipmentService.any_instance.stub(:search_equipment).and_return([equipment])
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([EquipmentPresenter.new(equipment)]))

        get :search

        assigns(:equipments).map(&:model).should eq([equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:search_equipment).and_return([build(:equipment)])

        get :search

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([build(:equipment)])
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))

        get :search

        assigns(:report_title).should eq('Search Equipment')
      end

      it 'assigns locations' do
        location = build(:location)
        LocationService.any_instance.stub(:get_all_locations).and_return([location])
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(Faker.new([]))

        get :search

        assigns(:locations).should == [location]
      end

      it 'assigns employees' do
        employee = build(:employee)
        controller.load_employee_service(Faker.new([employee]))
        fake_equipment_list_presenter = Faker.new([EmployeePresenter.new(employee)])
        #noinspection RubyArgCount
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

      it 'should return locations when assignee is Location' do
        location = create(:location, name: 'Oz')
        fake_employee_service = controller.load_location_service(Faker.new([location]))

        get :ajax_assignee, {assignee: 'Location'}

        fake_employee_service.received_message.should == :get_all_locations
        json = JSON.parse(response.body)
        json.should == [
          [location.id, 'Oz']
        ]
      end

      it 'should return sorted employees when assignee is Employee' do
        employee = create(:employee, first_name: 'Wendy', last_name: 'Wizard')
        fake_employee_service = controller.load_employee_service(Faker.new([employee]))
        fake_employee_list_presenter = Faker.new([EmployeePresenter.new(employee)])
        #noinspection RubyArgCount
        EmployeeListPresenter.stub(:new).and_return(fake_employee_list_presenter)

        get :ajax_assignee, {assignee: 'Employee'}

        fake_employee_service.received_message.should == :get_all_employees
        fake_employee_list_presenter.received_message.should == :sort
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
        LocationService.any_instance.should_receive(:get_all_locations).once.and_return([location])
        get :ajax_assignee, {assignee: 'Location'}
        json = JSON.parse(response.body)
        json.should == [
          [location.id, 'Oz']
        ]
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

