require 'spec_helper'

describe AutoRecertificationsController do

  describe '#new' do
    context 'as a certification user' do
      let(:customer) { create(:customer) }
      let(:certification_type) { create(:units_based_certification_type, customer: customer) }
      let(:certification) { build(:units_based_certification) }

      before do
        sign_in stub_certification_user(customer)
        CertificationType.stub(:find).with(certification_type.id.to_s).and_return(certification_type)
        certification_type.stub(:valid_certifications).and_return([certification])
      end

      it 'assign certification_type in @certification_type' do

        get :new, {certification_type_id: certification_type.id}, {}

        assigns(:certification_type).should == certification_type
      end

      it 'assign valid certifications in @valid_certifications' do

        get :new, {certification_type_id: certification_type.id}, {}

        assigns(:certifications).should == [certification]
      end
    end

    context 'as a guest user' do
      before { sign_in stub_guest_user }

      let(:certification_type) { create(:units_based_certification_type) }
      let(:certification) { create(:units_based_certification, certification_type: certification_type) }

      it 'does not assign certification_type in @certification_type' do

        get :new, {certification_type_id: certification_type.id}, {}

        assigns(:certification_type).should be_nil
      end

      it 'does not assign valid certifications in @valid_certifications' do

        get :new, {certification_type_id: certification_type.id}, {}

        assigns(:certifications).should be_nil
      end
    end

    context 'as an admin user' do
      let(:customer) { create(:customer) }
      let(:certification_type) { create(:units_based_certification_type, customer: customer) }
      let(:certification) { create(:units_based_certification, certification_type: certification_type) }

      before do
        sign_in stub_admin
        invalid_certification = create(:certification, certification_type: certification_type)
        invalid_certification.update_attribute(:units_achieved, certification_type.units_required - 1)
        other_units_based_certification_type = create(:units_based_certification_type, customer: create(:customer))
        create(:units_based_certification, certification_type: other_units_based_certification_type)
        other_date_based_certification_type = create(:date_based_certification_type, customer: create(:customer))
        create(:date_based_certification, certification_type: other_date_based_certification_type)
        certification.update_attribute(:units_achieved, certification_type.units_required)
      end

      it 'assign certification_type in @certification_type' do

        get :new, {certification_type_id: certification_type.id}, {}

        assigns(:certification_type).should == certification_type
      end

      it 'assign valid certifications in @valid_certifications' do

        get :new, {certification_type_id: certification_type.id}, {}

        assigns(:certifications).should == [certification]
      end
    end

    context 'as a guest user' do
      before { sign_in stub_guest_user }

      let(:certification_type) { create(:units_based_certification_type) }
      let(:certification) { create(:units_based_certification, certification_type: certification_type) }

      it 'does not assign certification_type in @certification_type' do

        get :new, {certification_type_id: certification_type.id}, {}

        assigns(:certification_type).should be_nil
      end

      it 'does not assign valid certifications in @valid_certifications' do

        get :new, {certification_type_id: certification_type.id}, {}

        assigns(:certifications).should be_nil
      end
    end
  end
end
