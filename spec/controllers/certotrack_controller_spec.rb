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
        CertificationService.any_instance.stub(:count_all_certifications).and_return(5)
        CertificationService.any_instance.stub(:count_recertification_required_certifications).and_return(4)
        CertificationService.any_instance.stub(:count_units_based_certifications).and_return(3)
        CertificationService.any_instance.stub(:count_expired_certifications).and_return(2)
        CertificationService.any_instance.stub(:count_expiring_certifications).and_return(1)

        get :home

        assigns(:total_certification_count).should eq(5)
        assigns(:total_recertification_required_certification_count).should eq(4)
        assigns(:total_units_based_certification_count).should eq(3)
        assigns(:total_expired_certification_count).should eq(2)
        assigns(:total_expiring_certification_count).should eq(1)
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
