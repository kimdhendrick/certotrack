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
        it 'calls CertificationTypesService' do
          CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
          post :create, {:certification_type => certification_type_attributes}, valid_session
        end

        it 'assigns a newly created certification_type as @certification_type' do
          CertificationTypesService.any_instance.stub(:create_certification_type).and_return(new_certification_type)
          post :create, {:certification_type => certification_type_attributes}, valid_session
          assigns(:certification_type).should be_a(CertificationType)
        end

        it 'redirects to the created certification_type' do
          CertificationTypesService.any_instance.stub(:create_certification_type).and_return(create_certification_type)
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

      it 'calls CertificationTypesService' do
        CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
        post :create, {:certification_type => certification_type_attributes}, valid_session
      end

      it 'assigns a newly created certification_type as @certification_type' do
        CertificationTypesService.any_instance.should_receive(:create_certification_type).once.and_return(new_certification_type)
        post :create, {:certification_type => certification_type_attributes}, valid_session
        assigns(:certification_type).should be_a(CertificationType)
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

  describe 'DELETE destroy' do
    context 'when certification_type user' do
      before do
        sign_in stub_certification_user
      end

      it 'calls CertificationTypeService' do
        certification_type = create_certification_type(customer: @customer)
        CertificationTypesService.any_instance.should_receive(:delete_certification_type).once

        delete :destroy, {:id => certification_type.to_param}, valid_session
      end

      it 'redirects to the certification_type list' do
        certification_type = create_certification_type(customer: @customer)
        CertificationTypesService.any_instance.should_receive(:delete_certification_type).once

        delete :destroy, {:id => certification_type.to_param}, valid_session

        response.should redirect_to(certification_types_path)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls certification_typeService' do
        certification_type = create_certification_type(customer: @customer)
        CertificationTypesService.any_instance.should_receive(:delete_certification_type).once

        delete :destroy, {:id => certification_type.to_param}, valid_session
      end
    end
  end

  describe 'GET index' do
    it 'calls get_all_certification_types with current_user and params' do
      my_user = stub_certification_user
      sign_in my_user
      @fake_certification_types_service = controller.load_certification_types_service(FakeService.new([]))
      params = {sort: 'name', direction: 'asc'}

      get :index, params

      @fake_certification_types_service.received_messages.should == [:get_all_certification_types]
      @fake_certification_types_service.received_params[0].should == my_user
      @fake_certification_types_service.received_params[1]['sort'].should == 'name'
      @fake_certification_types_service.received_params[1]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns certification_types as @certification_types' do
        certification_type = new_certification_type
        CertificationTypesService.any_instance.stub(:get_all_certification_types).and_return([certification_type])

        get :index

        assigns(:certification_types).should eq([certification_type])
      end

      it 'assigns certification_types_count' do
        CertificationTypesService.any_instance.stub(:get_all_certification_types).and_return([new_certification_type])

        get :index

        assigns(:certification_types_count).should eq(1)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns certification_types as @certification_types' do
        certification_type = new_certification_type
        CertificationTypesService.any_instance.stub(:get_all_certification_types).and_return([certification_type])

        get :index

        assigns(:certification_types).should eq([certification_type])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign certification_types as @certification_types' do
          certification_type = new_certification_type
          CertificationTypesService.any_instance.stub(:get_all_certification_types).and_return([certification_type])

          get :index

          assigns(:certification_types).should be_nil
        end
      end
    end
  end

  describe 'GET search' do
    it 'calls get_all_certification_types with current_user and params' do
      my_user = stub_certification_user
      sign_in my_user
      fake_certification_types_service = controller.load_certification_types_service(FakeService.new([]))
      params = {sort: 'name', direction: 'asc'}

      get :search, params

      fake_certification_types_service.received_messages.should == [:get_all_certification_types]
      fake_certification_types_service.received_params[0].should == my_user
      fake_certification_types_service.received_params[1]['sort'].should == 'name'
      fake_certification_types_service.received_params[1]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_certification_user
      end

      it 'assigns certification_types as @certification_types' do
        certification_type = new_certification_type(customer: @customer)

        CertificationTypesService.any_instance.stub(:get_all_certification_types).and_return([certification_type])

        get :search

        assigns(:certification_types).should eq([certification_type])
      end

      it 'assigns certification_types_count' do
        CertificationTypesService.any_instance.stub(:get_all_certification_types).and_return([new_certification_type])

        get :search

        assigns(:certification_types_count).should eq(1)
      end
    end
  end
end