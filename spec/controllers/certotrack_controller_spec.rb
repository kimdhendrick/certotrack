require 'spec_helper'

describe CertotrackController do

  let(:customer) { create(:customer) }

  describe 'GET home' do
    context 'an equipment user' do
      it 'assigns equipment counts' do
        sign_in stub_equipment_user(customer)

        EquipmentService.any_instance.stub(:count_all_equipment).and_return(3)
        EquipmentService.any_instance.stub(:count_expired_equipment).and_return(2)
        EquipmentService.any_instance.stub(:count_expiring_equipment).and_return(1)

        get :home

        assigns(:total_equipment_count).should eq(3)
        assigns(:expired_equipment_count).should eq(2)
        assigns(:expiring_equipment_count).should eq(1)
      end
    end

    context 'an non-equipment user' do
      it 'assigns equipment counts' do
        sign_in stub_guest_user

        get :home

        assigns(:total_equipment_count).should be_nil
        assigns(:expired_equipment_count).should be_nil
        assigns(:expiring_equipment_count).should be_nil
      end
    end

    context 'a certification user' do
      it 'assigns certification counts' do
        sign_in stub_certification_user(customer)
        fake_certification_service = Faker.new(3)
        controller.load_certification_service(fake_certification_service)

        get :home

        assigns(:total_certification_count).should eq(3)
        fake_certification_service.received_message.should == :count_all_certifications
      end
    end

    context 'an non-certification user' do
      it 'assigns certification counts' do
        sign_in stub_guest_user

        get :home

        assigns(:total_certification_count).should be_nil
      end
    end
  end
end
