require 'spec_helper'

describe AutoRecertificationsController do
  let(:customer) { create(:customer) }
  let(:certification_type) { create(:units_based_certification_type, customer: customer) }

  describe '#new' do
    context 'as a certification user' do
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

  describe '#create' do

    context 'as an certification user' do
      let(:certification_service) { double('certification_service') }
      let(:certification) { create(:units_based_certification, customer: customer) }

      before do
        sign_in stub_certification_user(customer)
        controller.load_certification_service(certification_service)
      end

      context 'when successful' do
        before do
          sign_in stub_certification_user(customer)
          certification_service.stub(:auto_recertify).and_return(:success)
        end

        it 'should redirect to the show certification type page' do
          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id]}

          response.should redirect_to(certification_type_path(certification_type))
        end

        it 'should provide a success notification' do
          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id]}

          flash[:notice].should == 'Auto Recertify successful.'
        end

        it 'should call CertificationService#auto_recertify' do
          controller.load_certification_service(certification_service)

          certification_service.should_receive(:auto_recertify).with([certification]).and_return(:success)

          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id]}
        end
      end

      context 'when no certifications selected' do

        it 'should report an error when no certification_ids present' do
          post :create, {certification_type_id: certification_type.id}

          flash[:error].should == 'Please select at least one certification.'
        end

        it 'should report an error when no certification_ids' do
          post :create, {certification_type_id: certification_type.id, certification_ids: []}

          flash[:error].should == 'Please select at least one certification.'
        end

        it 'should render the new view' do
          post :create, {certification_type_id: certification_type.id}

          response.should redirect_to(new_certification_type_auto_recertification_path(certification_type))
        end
      end

      context 'when at least one certification has an error' do
        before { certification_service.stub(:auto_recertify).and_return(:failure) }

        it 'should report an error' do
          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id]}

          flash[:error].should == 'A system error has occurred. Please contact support@certotrack.com.'
        end

        it 'should redirect_to new' do
          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id]}

          response.should redirect_to(new_certification_type_auto_recertification_path(certification_type))
        end
      end

      context 'when not authorized for one (or more) certifications' do
        it 'should redirect_to not authorized' do
          certification = create(:certification, customer: customer)
          another_certification = create(:certification)

          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id, another_certification.id]}

          response.should redirect_to(root_path)
        end
      end
    end

    context 'as admin user' do
      let(:certification_service) { double('certification_service') }
      let(:certification) { create(:units_based_certification) }

      context 'when successful' do
        before do
          sign_in stub_admin
          certification_service.stub(:auto_recertify).and_return(:success)
          controller.load_certification_service(certification_service)
        end

        it 'should redirect to the show certification type page' do
          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id]}

          response.should redirect_to(certification_type_path(certification_type))
        end

        it 'should provide a success notification' do
          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id]}

          flash[:notice].should == 'Auto Recertify successful.'
        end

        it 'should call CertificationService#auto_recertify' do
          controller.load_certification_service(certification_service)

          certification_service.should_receive(:auto_recertify).with([certification]).and_return(:success)

          post :create, {certification_type_id: certification_type.id, certification_ids: [certification.id]}
        end
      end

    end
  end

  context 'as a guest user' do
    before { sign_in stub_guest_user }

    let(:certification_type) { create(:units_based_certification_type) }

    it 'does not assign certification_type in @certification_type' do

      post :create, {certification_type_id: certification_type.id}, {}

      assigns(:certification_type).should be_nil
    end
  end
end
