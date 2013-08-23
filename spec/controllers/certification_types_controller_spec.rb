require 'spec_helper'

describe CertificationTypesController do

  before do
    @customer = create_customer
  end

  describe 'GET new' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns a new certification type as @certification_type' do
        get :new, {}, valid_session
        assigns(:certification_type).should be_a_new(CertificationType)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns a new certification_type as @certification_type' do
        get :new, {}, valid_session
        assigns(:certification_type).should be_a_new(CertificationType)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        get :new, {}, valid_session
        assigns(:certification_type).should be_nil
      end
    end
  end

  describe 'POST create' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user
      end

      describe 'with valid params' do
        it 'creates a new CertificationType' do
          CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
          expect {
            post :create, {:certification_type => certification_type_attributes}, valid_session
          }.to change(CertificationType, :count).by(1)
        end

        it 'assigns a newly created certification_type as @certification_type' do
          CertificationTypesService.any_instance.stub(:create_certification_type).and_return(new_certification_type)
          post :create, {:certification_type => certification_type_attributes}, valid_session
          assigns(:certification_type).should be_a(CertificationType)
          assigns(:certification_type).should be_persisted
        end

        it 'redirects to the created certification_type' do
          CertificationTypesService.any_instance.stub(:create_certification_type).and_return(new_certification_type)
          post :create, {:certification_type => certification_type_attributes}, valid_session
          response.should redirect_to(CertificationType.last)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved certification_type as @certification_type' do
          CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
          CertificationType.any_instance.stub(:save).and_return(false)

          post :create, {:certification_type => {'name' => 'invalid value'}}, valid_session

          assigns(:certification_type).should be_a_new(CertificationType)
        end

        it "re-renders the 'new' template" do
          CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
          CertificationType.any_instance.stub(:save).and_return(false)
          post :create, {:certification_type => {'name' => 'invalid value'}}, valid_session
          response.should render_template('new')
        end

        it 'assigns @inspection_intervals' do
          CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
          CertificationType.any_instance.stub(:save).and_return(false)
          post :create, {:certification_type => {'name' => 'invalid value'}}, valid_session
          assigns(:inspection_intervals).should eq(InspectionInterval.all.to_a)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'creates a new CertificationType' do
        CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
        expect {
          post :create, {:certification_type => certification_type_attributes}, valid_session
        }.to change(CertificationType, :count).by(1)
      end

      it 'assigns a newly created certification_type as @certification_type' do
        CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
        post :create, {:certification_type => certification_type_attributes}, valid_session
        assigns(:certification_type).should be_a(CertificationType)
        assigns(:certification_type).should be_persisted
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        expect {
          post :create, {:certification_type => certification_type_attributes}, valid_session
        }.not_to change(CertificationType, :count)
        assigns(:certification_type).should be_nil
      end
    end
  end
end

