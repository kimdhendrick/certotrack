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

        it 'assigns @intervals' do
          CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
          CertificationType.any_instance.stub(:save).and_return(false)
          post :create, {:certification_type => {'name' => 'invalid value'}}, valid_session
          assigns(:intervals).should eq(Interval.all.to_a)
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

  describe 'GET edit' do
    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns the requested certification_type as @certification_type' do
        certification_type = create_certification_type(customer: @customer)
        get :edit, {:id => certification_type.to_param}, valid_session
        assigns(:certification_type).should eq(certification_type)
      end

      it 'assigns @intervals' do
        certification_type = create_certification_type(customer: @customer)
        get :edit, {:id => certification_type.to_param}, valid_session
        assigns(:intervals).should eq(Interval.all.to_a)
      end

    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns the requested certification_type as @certification_type' do
        certification_type = create_certification_type(customer: @customer)
        get :edit, {:id => certification_type.to_param}, valid_session
        assigns(:certification_type).should eq(certification_type)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        certification_type = create_certification_type(customer: @customer)
        get :edit, {:id => certification_type.to_param}, valid_session
        assigns(:certification_type).should be_nil
      end
    end
  end

  describe 'PUT update' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user
      end

      describe 'with valid params' do
        it 'updates the requested certification_type' do
          certification_type = create_certification_type(customer: @customer)
          CertificationTypesService.any_instance.should_receive(:update_certification_type).once

          put :update, {:id => certification_type.to_param, :certification_type =>
            {
              'name' => 'Box',
              'interval' => 'Annually',
              'units_required' => '99'
            }
          }, valid_session
        end

        it 'assigns the requested certification_type as @certification_type' do
          CertificationTypesService.any_instance.stub(:update_certification_type).and_return(true)
          certification_type = create_certification_type(customer: @customer)
          put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, valid_session
          assigns(:certification_type).should eq(certification_type)
        end

        it 'redirects to the certification_type' do
          CertificationTypesService.any_instance.stub(:update_certification_type).and_return(true)
          certification_type = create_certification_type(customer: @customer)
          put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, valid_session
          response.should redirect_to(certification_type)
        end
      end

      describe 'with invalid params' do
        it 'assigns the certification_type as @certification_type' do
          certification_type = create_certification_type(customer: @customer)
          CertificationTypesService.any_instance.stub(:update_certification_type).and_return(false)
          put :update, {:id => certification_type.to_param, :certification_type => {'name' => 'invalid value'}}, valid_session
          assigns(:certification_type).should eq(certification_type)
        end

        it "re-renders the 'edit' template" do
          certification_type = create_certification_type(customer: @customer)
          CertificationTypesService.any_instance.stub(:update_certification_type).and_return(false)
          put :update, {:id => certification_type.to_param, :certification_type => {'name' => 'invalid value'}}, valid_session
          response.should render_template('edit')
        end

        it 'assigns @intervals' do
          certification_type = create_certification_type(customer: @customer)
          CertificationTypesService.any_instance.stub(:update_certification_type).and_return(false)
          put :update, {:id => certification_type.to_param, :certification_type => {'name' => 'invalid value'}}, valid_session
          assigns(:intervals).should eq(Interval.all.to_a)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'updates the requested certification_type' do
        certification_type = create_certification_type(customer: @customer)
        CertificationTypesService.any_instance.should_receive(:update_certification_type).once

        put :update, {:id => certification_type.to_param, :certification_type =>
          {
            'name' => 'Box',
            'interval' => 'Annually',
            'units_required' => 89
          }
        }, valid_session
      end

      it 'assigns the requested certification_type as @certification_type' do
        certification_type = create_certification_type(customer: @customer)
        CertificationTypesService.any_instance.stub(:update_certification_type).and_return(certification_type)
        put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, valid_session
        assigns(:certification_type).should eq(certification_type)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign certification_type as @certification_type' do
        certification_type = create_certification_type(customer: @customer)
        put :update, {:id => certification_type.to_param, :certification_type => certification_type_attributes}, valid_session
        assigns(:certification_type).should be_nil
      end
    end
  end
end