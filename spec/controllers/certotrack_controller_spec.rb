require 'spec_helper'

describe CertotrackController do

  before do
    @customer = create(:customer)
  end

  describe 'GET home' do
    context 'an equipment user'

    it 'assigns equipment counts' do
      user = stub_equipment_user
      sign_in user

      EquipmentService.any_instance.stub(:count_all_equipment).and_return(3)
      EquipmentService.any_instance.stub(:count_expired_equipment).and_return(2)
      EquipmentService.any_instance.stub(:count_expiring_equipment).and_return(1)

      get :home

      assigns(:total_equipment_count).should eq(3)
      assigns(:expired_equipment_count).should eq(2)
      assigns(:expiring_equipment_count).should eq(1)
    end

    context 'an non-equipment user'
    it 'assigns equipment counts' do
      user = stub_guest_user
      sign_in user

      get :home

      assigns(:total_equipment_count).should be_nil
      assigns(:expired_equipment_count).should be_nil
      assigns(:expiring_equipment_count).should be_nil
    end
  end
end
