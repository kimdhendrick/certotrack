require 'spec_helper'

describe EquipmentController do

  before do
    @customer = create_customer
  end

  describe 'GET index' do
    it 'calls get_all_equipment with current_user and params' do
      my_user = stub_equipment_user
      sign_in my_user
      @fake_equipment_service = controller.load_equipment_service(FakeEquipmentService.new)
      params = {sort: 'name', direction: 'asc'}

      get :index, params

      @fake_equipment_service.received_messages.should == [:get_all_equipment]
      @fake_equipment_service.received_current_user.should == my_user
      @fake_equipment_service.received_params['sort'].should == 'name'
      @fake_equipment_service.received_params['direction'].should == 'asc'
    end

    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'assigns equipment as @equipment' do
        equipment = new_equipment
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

        get :index

        assigns(:equipment).should eq([equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([new_equipment])

        get :index

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([new_equipment])

        get :index

        assigns(:report_title).should eq('All Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        equipment = new_equipment
        EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

        get :index

        assigns(:equipment).should eq([equipment])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign equipment as @equipment' do
          equipment = new_equipment
          EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

          get :index

          assigns(:equipment).should be_nil
        end
      end
    end
  end

  describe 'GET expired' do
    it 'calls get_expired_equipment with current_user and params' do
      my_user = stub_equipment_user
      sign_in my_user
      @fake_equipment_service = controller.load_equipment_service(FakeEquipmentService.new)
      params = {sort: 'name', direction: 'asc'}

      get :expired, params

      @fake_equipment_service.received_messages.should == [:get_expired_equipment]
      @fake_equipment_service.received_current_user.should == my_user
      @fake_equipment_service.received_params['sort'].should == 'name'
      @fake_equipment_service.received_params['direction'].should == 'asc'
    end

    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'assigns equipment as @equipment' do
        expired_equipment = create_expired_equipment(customer: @customer)

        EquipmentService.any_instance.stub(:get_expired_equipment).and_return([expired_equipment])

        get :expired

        assigns(:equipment).should eq([expired_equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:get_expired_equipment).and_return([new_equipment])

        get :expired

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_expired_equipment).and_return([new_equipment])

        get :expired

        assigns(:report_title).should eq('Expired Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        expired_equipment = create_expired_equipment(customer: @customer)
        EquipmentService.any_instance.stub(:get_expired_equipment).and_return([expired_equipment])

        get :expired

        assigns(:equipment).should eq([expired_equipment])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET expired' do
        it 'does not assign equipment as @equipment' do
          equipment = new_equipment
          EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

          get :expired

          assigns(:equipment).should be_nil
        end
      end
    end
  end

  describe 'GET expiring' do
    it 'calls get_expiring_equipment with current_user and params' do
      my_user = stub_equipment_user
      sign_in my_user
      @fake_equipment_service = controller.load_equipment_service(FakeEquipmentService.new)
      params = {sort: 'name', direction: 'asc'}

      get :expiring, params

      @fake_equipment_service.received_messages.should == [:get_expiring_equipment]
      @fake_equipment_service.received_current_user.should == my_user
      @fake_equipment_service.received_params['sort'].should == 'name'
      @fake_equipment_service.received_params['direction'].should == 'asc'
    end

    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'assigns equipment as @equipment' do
        expiring_equipment = create_expiring_equipment(customer: @customer)

        EquipmentService.any_instance.stub(:get_expiring_equipment).and_return([expiring_equipment])

        get :expiring

        assigns(:equipment).should eq([expiring_equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:get_expiring_equipment).and_return([new_equipment])

        get :expiring

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_expiring_equipment).and_return([new_equipment])

        get :expiring

        assigns(:report_title).should eq('Expiring Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        expiring_equipment = create_expiring_equipment(customer: @customer)
        EquipmentService.any_instance.stub(:get_expiring_equipment).and_return([expiring_equipment])

        get :expiring

        assigns(:equipment).should eq([expiring_equipment])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET expiring' do
        it 'does not assign equipment as @equipment' do
          equipment = new_equipment
          EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

          get :expiring

          assigns(:equipment).should be_nil
        end
      end
    end
  end

  describe 'GET noninspectable' do
    it 'calls get_noninspectable_equipment with current_user and params' do
      my_user = stub_equipment_user
      sign_in my_user
      @fake_equipment_service = controller.load_equipment_service(FakeEquipmentService.new)
      params = {sort: 'name', direction: 'asc'}

      get :noninspectable, params

      @fake_equipment_service.received_messages.should == [:get_noninspectable_equipment]
      @fake_equipment_service.received_current_user.should == my_user
      @fake_equipment_service.received_params['sort'].should == 'name'
      @fake_equipment_service.received_params['direction'].should == 'asc'
    end

    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'assigns equipment as @equipment' do
        noninspectable_equipment = create_noninspectable_equipment(customer: @customer)

        EquipmentService.any_instance.stub(:get_noninspectable_equipment).and_return([noninspectable_equipment])

        get :noninspectable

        assigns(:equipment).should eq([noninspectable_equipment])
      end

      it 'assigns equipment_count' do
        EquipmentService.any_instance.stub(:get_noninspectable_equipment).and_return([new_equipment])

        get :noninspectable

        assigns(:equipment_count).should eq(1)
      end

      it 'assigns report_title' do
        EquipmentService.any_instance.stub(:get_noninspectable_equipment).and_return([new_equipment])

        get :noninspectable

        assigns(:report_title).should eq('Non-Inspectable Equipment List')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        noninspectable_equipment = create_noninspectable_equipment(customer: @customer)
        EquipmentService.any_instance.stub(:get_noninspectable_equipment).and_return([noninspectable_equipment])

        get :noninspectable

        assigns(:equipment).should eq([noninspectable_equipment])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET noninspectable' do
        it 'does not assign equipment as @equipment' do
          equipment = new_equipment
          EquipmentService.any_instance.stub(:get_all_equipment).and_return([equipment])

          get :noninspectable

          assigns(:equipment).should be_nil
        end
      end
    end
  end

  describe 'GET show' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'assigns equipment as @equipment' do
        equipment = create_equipment(customer: @customer)
        get :show, {:id => equipment.to_param}, valid_session
        assigns(:equipment).should eq(equipment)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns equipment as @equipment' do
        equipment = create_equipment(customer: @customer)
        get :show, {:id => equipment.to_param}, valid_session
        assigns(:equipment).should eq(equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        equipment = create_equipment(customer: @customer)
        get :show, {:id => equipment.to_param}, valid_session
        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'GET new' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'assigns a new equipment as @equipment' do
        get :new, {}, valid_session
        assigns(:equipment).should be_a_new(Equipment)
      end

      it 'assigns @inspection_intervals' do
        equipment = create_equipment(customer: @customer)
        get :new, {:id => equipment.to_param}, valid_session
        assigns(:inspection_intervals).should eq(InspectionInterval.all.to_a)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns a new equipment as @equipment' do
        get :new, {}, valid_session
        assigns(:equipment).should be_a_new(Equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        get :new, {}, valid_session
        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'GET edit' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'assigns the requested equipment as @equipment' do
        equipment = create_equipment(customer: @customer)
        get :edit, {:id => equipment.to_param}, valid_session
        assigns(:equipment).should eq(equipment)
      end

      it 'assigns @inspection_intervals' do
        equipment = create_equipment(customer: @customer)
        get :edit, {:id => equipment.to_param}, valid_session
        assigns(:inspection_intervals).should eq(InspectionInterval.all.to_a)
      end

    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns the requested equipment as @equipment' do
        equipment = create_equipment(customer: @customer)
        get :edit, {:id => equipment.to_param}, valid_session
        assigns(:equipment).should eq(equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        equipment = create_equipment(customer: @customer)
        get :edit, {:id => equipment.to_param}, valid_session
        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'POST create' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      describe 'with valid params' do
        it 'creates a new Equipment' do
          EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(new_equipment)
          expect {
            post :create, {:equipment => equipment_attributes}, valid_session
          }.to change(Equipment, :count).by(1)
        end

        it 'assigns a newly created equipment as @equipment' do
          EquipmentService.any_instance.stub(:create_equipment).and_return(new_equipment)
          post :create, {:equipment => equipment_attributes}, valid_session
          assigns(:equipment).should be_a(Equipment)
          assigns(:equipment).should be_persisted
        end

        it 'redirects to the created equipment' do
          EquipmentService.any_instance.stub(:create_equipment).and_return(new_equipment)
          post :create, {:equipment => equipment_attributes}, valid_session
          response.should redirect_to(Equipment.last)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved equipment as @equipment' do
          EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(new_equipment)
          Equipment.any_instance.stub(:save).and_return(false)

          post :create, {:equipment => {'name' => 'invalid value'}}, valid_session

          assigns(:equipment).should be_a_new(Equipment)
        end

        it "re-renders the 'new' template" do
          EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(new_equipment)
          Equipment.any_instance.stub(:save).and_return(false)
          post :create, {:equipment => {'name' => 'invalid value'}}, valid_session
          response.should render_template('new')
        end

        it 'assigns @inspection_intervals' do
          EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(new_equipment)
          Equipment.any_instance.stub(:save).and_return(false)
          post :create, {:equipment => {'name' => 'invalid value'}}, valid_session
          assigns(:inspection_intervals).should eq(InspectionInterval.all.to_a)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'creates a new Equipment' do
        EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(new_equipment)
        expect {
          post :create, {:equipment => equipment_attributes}, valid_session
        }.to change(Equipment, :count).by(1)
      end

      it 'assigns a newly created equipment as @equipment' do
        EquipmentService.any_instance.should_receive(:create_equipment).once.and_return(new_equipment)
        post :create, {:equipment => equipment_attributes}, valid_session
        assigns(:equipment).should be_a(Equipment)
        assigns(:equipment).should be_persisted
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        expect {
          post :create, {:equipment => equipment_attributes}, valid_session
        }.not_to change(Equipment, :count)
        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'PUT update' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      describe 'with valid params' do
        it 'updates the requested equipment' do
          equipment = create_equipment(customer: @customer)
          EquipmentService.any_instance.should_receive(:update_equipment).once

          put :update, {:id => equipment.to_param, :equipment =>
            {
              'name' => 'Box',
              'serial_number' => 'newSN',
              'inspection_interval' => 'Annually',
              'last_inspection_date' => '01/01/2001',
              'notes' => 'some new notes'
            }
          }, valid_session
        end

        it 'assigns the requested equipment as @equipment' do
          EquipmentService.any_instance.stub(:update_equipment).and_return(true)
          equipment = create_equipment(customer: @customer)
          put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, valid_session
          assigns(:equipment).should eq(equipment)
        end

        it 'redirects to the equipment' do
          EquipmentService.any_instance.stub(:update_equipment).and_return(true)
          equipment = create_equipment(customer: @customer)
          put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, valid_session
          response.should redirect_to(equipment)
        end
      end

      describe 'with invalid params' do
        it 'assigns the equipment as @equipment' do
          equipment = create_equipment(customer: @customer)
          EquipmentService.any_instance.stub(:update_equipment).and_return(false)
          put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, valid_session
          assigns(:equipment).should eq(equipment)
        end

        it "re-renders the 'edit' template" do
          equipment = create_equipment(customer: @customer)
          EquipmentService.any_instance.stub(:update_equipment).and_return(false)
          put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, valid_session
          response.should render_template('edit')
        end

        it 'assigns @inspection_intervals' do
          equipment = create_equipment(customer: @customer)
          EquipmentService.any_instance.stub(:update_equipment).and_return(false)
          put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, valid_session
          assigns(:inspection_intervals).should eq(InspectionInterval.all.to_a)
        end
      end

    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'updates the requested equipment' do
        equipment = create_equipment(customer: @customer)
        EquipmentService.any_instance.should_receive(:update_equipment).once

        put :update, {:id => equipment.to_param, :equipment =>
          {
            'name' => 'Box',
            'serial_number' => 'newSN',
            'inspection_interval' => 'Annually',
            'last_inspection_date' => '01/01/2001',
            'notes' => 'some new notes'
          }
        }, valid_session
      end

      it 'assigns the requested equipment as @equipment' do
        equipment = create_equipment(customer: @customer)
        EquipmentService.any_instance.stub(:update_equipment).and_return(equipment)
        put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, valid_session
        assigns(:equipment).should eq(equipment)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign equipment as @equipment' do
        equipment = create_equipment(customer: @customer)
        put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, valid_session
        assigns(:equipment).should be_nil
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'destroys the requested equipment' do
        equipment = create_equipment(customer: @customer)
        expect {
          delete :destroy, {:id => equipment.to_param}, valid_session
        }.to change(Equipment, :count).by(-1)
      end

      it 'redirects to the equipment list' do
        equipment = create_equipment(customer: @customer)
        delete :destroy, {:id => equipment.to_param}, valid_session
        response.should redirect_to(equipment_index_url)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'destroys the requested equipment' do
        equipment = create_equipment(customer: @customer)
        expect {
          delete :destroy, {:id => equipment.to_param}, valid_session
        }.to change(Equipment, :count).by(-1)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not destroy any equipment' do
        equipment = create_equipment(customer: @customer)
        expect {
          delete :destroy, {:id => equipment.to_param}, valid_session
        }.not_to change(Equipment, :count)
      end
    end
  end

  describe 'GET ajax_assignee' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user
      end

      it 'should return locations when assignee is Location' do
        location = create_location(name: 'Oz')
        LocationService.any_instance.should_receive(:get_all_locations).once.and_return([location])
        get :ajax_assignee, {assignee: 'Location'}
        json = JSON.parse(response.body)
        json.should == [
          [location.id, 'Oz']
        ]
      end

      it 'should return employees when assignee is Employee' do
        employee = create_employee(first_name: 'The', last_name: 'Wizard')
        EmployeeService.any_instance.should_receive(:get_all_employees).once.and_return([employee])
        get :ajax_assignee, {assignee: 'Employee'}
        json = JSON.parse(response.body)
        json.should == [
          [employee.id, 'Wizard, The']
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
        location = create_location(name: 'Oz')
        LocationService.any_instance.should_receive(:get_all_locations).once.and_return([location])
        get :ajax_assignee, {assignee: 'Location'}
        json = JSON.parse(response.body)
        json.should == [
          [location.id, 'Oz']
        ]
      end
    end
  end

  class FakeEquipmentService
    attr_accessor :received_messages, :received_current_user, :received_params

    def method_missing(m, *args, &block)
      _record_received_params(m.to_sym, args[0], args[1])
    end

    private

    def _record_received_params(message, current_user, params)
      @received_messages ||= []
      @received_messages << message
      @received_current_user = current_user
      @received_params = params
    end
  end
end


