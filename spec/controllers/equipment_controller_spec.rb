require 'spec_helper'

describe EquipmentController do

  before do
    @customer = create_valid_customer
    # Should not do this!  Can't get devise to work in test, have tried:
    #@request.env["devise.mapping"] = Devise.mappings[:user]
    #@user = new_valid_user(roles_mask:1)
    #sign_in @user
    # Sigh... yet another mystery...
    controller.stub(:current_user).and_return(
      create_valid_user(roles: ['admin'],
                     customer: @customer)
    )
  end

  describe 'GET index' do
    it 'assigns own equipment as @equipment' do
      equipment = create_valid_equipment(customer: @customer)

      get :index

      assigns(:equipment).should eq([equipment])
    end

    it "does not assign other customer's equipment as @equipment" do
      my_equipment = create_valid_equipment(customer: @customer)
      other_equipment = create_valid_equipment(customer: create_valid_customer)

      get :index

      assigns(:equipment).should eq([my_equipment])
    end
  end

  describe 'GET show' do
    it 'assigns the requested equipment as @equipment' do
      equipment = create_valid_equipment
      get :show, {:id => equipment.to_param}, valid_session
      assigns(:equipment).should eq(equipment)
    end
  end

  describe 'GET new' do
    it 'assigns a new equipment as @equipment' do
      get :new, {}, valid_session
      assigns(:equipment).should be_a_new(Equipment)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested equipment as @equipment' do
      equipment = create_valid_equipment
      get :edit, {:id => equipment.to_param}, valid_session
      assigns(:equipment).should eq(equipment)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Equipment' do
        expect {
          post :create, {:equipment => equipment_attributes}, valid_session
        }.to change(Equipment, :count).by(1)
      end

      it 'sets the customer on the Equipment' do
        post :create, {:equipment => equipment_attributes}, valid_session

        equipment = Equipment.last

        equipment.customer.should == @customer
      end

      it 'assigns a newly created equipment as @equipment' do
        post :create, {:equipment => equipment_attributes}, valid_session
        assigns(:equipment).should be_a(Equipment)
        assigns(:equipment).should be_persisted
      end

      it 'redirects to the created equipment' do
        post :create, {:equipment => equipment_attributes}, valid_session
        response.should redirect_to(Equipment.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved equipment as @equipment' do
        # Trigger the behavior that occurs when invalid params are submitted
        Equipment.any_instance.stub(:save).and_return(false)
        post :create, {:equipment => {'name' => 'invalid value'}}, valid_session
        assigns(:equipment).should be_a_new(Equipment)
      end

      it "re-renders the 'new' template" do
        Equipment.any_instance.stub(:save).and_return(false)
        post :create, {:equipment => {'name' => 'invalid value'}}, valid_session
        response.should render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested equipment' do
        equipment = create_valid_equipment
        Equipment.any_instance.should_receive(:update).with(
          {
            'name' => 'Box',
            'serial_number' => 'newSN',
            'inspection_interval' => 'Annually',
            'last_inspection_date' => '01/01/2001',
            'inspection_type' => 'Not Inspectable',
            'notes' => 'some new notes'
          }
        )
        put :update, {:id => equipment.to_param, :equipment =>
          {
            'name' => 'Box',
            'serial_number' => 'newSN',
            'inspection_interval' => 'Annually',
            'last_inspection_date' => '01/01/2001',
            'inspection_type' => 'Not Inspectable',
            'notes' => 'some new notes'
          }
        }, valid_session
      end

      it 'assigns the requested equipment as @equipment' do
        equipment = create_valid_equipment
        put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, valid_session
        assigns(:equipment).should eq(equipment)
      end

      it 'redirects to the equipment' do
        equipment = create_valid_equipment
        put :update, {:id => equipment.to_param, :equipment => equipment_attributes}, valid_session
        response.should redirect_to(equipment)
      end
    end

    describe 'with invalid params' do
      it 'assigns the equipment as @equipment' do
        equipment = create_valid_equipment
        Equipment.any_instance.stub(:save).and_return(false)
        put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, valid_session
        assigns(:equipment).should eq(equipment)
      end

      it "re-renders the 'edit' template" do
        equipment = create_valid_equipment
        Equipment.any_instance.stub(:save).and_return(false)
        put :update, {:id => equipment.to_param, :equipment => {'name' => 'invalid value'}}, valid_session
        response.should render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested equipment' do
      equipment = create_valid_equipment
      expect {
        delete :destroy, {:id => equipment.to_param}, valid_session
      }.to change(Equipment, :count).by(-1)
    end

    it 'redirects to the equipment list' do
      equipment = create_valid_equipment
      delete :destroy, {:id => equipment.to_param}, valid_session
      response.should redirect_to(equipment_index_url)
    end
  end

end
