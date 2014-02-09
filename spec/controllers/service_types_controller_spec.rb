require 'spec_helper'

describe ServiceTypesController do
  let(:customer) { build(:customer) }
  let(:service_type) { build(:service_type) }
  let(:fake_service_type_service) { Faker.new(create(:service_type)) }
  let(:fake_service_type_service_non_persisted) { Faker.new(build(:service_type)) }

  describe 'GET #index' do
    context 'when vehicle user' do
      before do
        @my_user = stub_vehicle_user(customer)
        sign_in @my_user
        controller.load_service_type_service(Faker.new([service_type]))
      end

      it 'calls get_all_service_types with current_user and params' do
        fake_service_type_service = controller.load_service_type_service(Faker.new([]))

        get :index, {}

        fake_service_type_service.received_messages.should == [:get_all_service_types]
        fake_service_type_service.received_params[0].should == @my_user
      end

      it 'presents service_types with ServiceTypeListPresenter' do
        controller.load_service_type_service(Faker.new([]))
        fake_service_type_list_presenter = Faker.new([])
        ServiceTypeListPresenter.stub(:new).and_return(fake_service_type_list_presenter)
        params = {sort: 'name', direction: 'asc'}

        get :index, params

        fake_service_type_list_presenter.received_message.should == :present
        fake_service_type_list_presenter.received_params[0]['sort'].should == 'name'
        fake_service_type_list_presenter.received_params[0]['direction'].should == 'asc'
      end

      it 'assigns service_types as @service_types' do
        get :index

        assigns(:service_types).map(&:model).should eq([service_type])
      end

      it 'assigns service_type_count' do
        get :index

        assigns(:service_type_count).should eq(1)
      end

      it 'assigns report_title' do
        get :index

        assigns(:report_title).should eq('All Service Types')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
        controller.load_service_type_service(Faker.new([service_type]))
      end

      it 'assigns service_types as @service_types' do
        get :index

        assigns(:service_types).map(&:model).should eq([service_type])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign service_types' do
          get :index

          assigns(:service_types).should be_nil
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when vehicle user' do
      before do
        @my_user = stub_vehicle_user(customer)
        sign_in @my_user
      end

      it 'assigns service_type as @service_type' do
        service_type = create(:service_type, customer: customer)

        get :show, {:id => service_type.to_param}, {}

        assigns(:service_type).should eq(service_type)
      end

      it 'assigns services' do
        service = create(:service)
        service_type = create(:service_type, customer: customer)
        fake_vehicle_service = Faker.new([service])
        controller.load_vehicle_servicing_service(fake_vehicle_service)

        get :show, {:id => service_type.to_param}, {}

        assigns(:services).map(&:model).should eq([service])
        fake_vehicle_service.received_message.should == :get_all_services_for_service_type
        fake_vehicle_service.received_params[0].should == service_type
      end

      it 'assigns non_serviced_vehicles' do
        non_serviced_vehicle = create(:vehicle, customer: customer)
        service_type = create(:service_type, customer: customer)
        fake_vehicle_service = Faker.new([non_serviced_vehicle])
        controller.load_vehicle_service(fake_vehicle_service)

        get :show, {:id => service_type.to_param}, {}

        assigns(:non_serviced_vehicles).map(&:model).should eq([non_serviced_vehicle])
        fake_vehicle_service.received_message.should == :get_all_non_serviced_vehicles_for
        fake_vehicle_service.received_params[0].should == service_type
      end

      it 'sorts serviced vehicles by status' do
        service = create(:service)
        service_type = create(:service_type, customer: customer)

        fake_vehicle_service_list_presenter = Faker.new([service])
        #noinspection RubyArgCount
        ServiceListPresenter.stub(:new).and_return(fake_vehicle_service_list_presenter)

        params = {
          id: service_type.id,
          sort: 'sort_key',
          direction: 'desc',
          options: 'serviced_vehicles'
        }

        get :show, params, {}

        fake_vehicle_service_list_presenter.received_params[0].should == {sort: 'sort_key', direction: 'desc'}
      end

      it 'sorts serviced vehicles by vehicle number' do
        service = create(:service)
        service_type = create(:service_type, customer: customer)

        fake_vehicle_service_list_presenter = Faker.new([service])
        #noinspection RubyArgCount
        ServiceListPresenter.stub(:new).and_return(fake_vehicle_service_list_presenter)

        params = {
          id: service_type.id,
          sort: 'sort_key',
          direction: 'desc',
          options: 'serviced_vehicles'
        }

        get :show, params, {}

        fake_vehicle_service_list_presenter.received_params[0].should == {sort: 'sort_key', direction: 'desc'}
      end

      it 'sorts non-serviced vehicles by vehicle number' do
        service = create(:service)
        service_type = create(:service_type, customer: customer)

        fake_vehicle_list_presenter = Faker.new([service])
        #noinspection RubyArgCount
        VehicleListPresenter.stub(:new).and_return(fake_vehicle_list_presenter)

        params = {
          id: service_type.id,
          sort: 'sort_key',
          direction: 'desc',
          options: 'unserviced_vehicles'
        }

        get :show, params, {}

        fake_vehicle_list_presenter.received_params[0].should == {sort: 'sort_key', direction: 'desc'}
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns service_type as @service_type' do
        service_type = create(:service_type, customer: customer)

        get :show, {:id => service_type.to_param}, {}

        assigns(:service_type).should eq(service_type)
      end

      it 'assigns services' do
        service = create(:service)
        service_type = create(:service_type, customer: customer)
        fake_vehicle_service = Faker.new([service])
        controller.load_vehicle_servicing_service(fake_vehicle_service)

        get :show, {:id => service_type.to_param}, {}

        assigns(:services).map(&:model).should eq([service])
        fake_vehicle_service.received_message.should == :get_all_services_for_service_type
        fake_vehicle_service.received_params[0].should == service_type
      end

      it 'assigns non_serviced_vehicles' do
        non_serviced_vehicle = create(:vehicle, customer: customer)
        service_type = create(:service_type, customer: customer)
        fake_vehicle_service = Faker.new([non_serviced_vehicle])
        controller.load_vehicle_service(fake_vehicle_service)

        get :show, {:id => service_type.to_param}, {}

        assigns(:non_serviced_vehicles).map(&:model).should eq([non_serviced_vehicle])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service_type as @service_type' do
        service_type = create(:service_type, customer: customer)

        get :show, {:id => service_type.to_param}, {}

        assigns(:service_type).should be_nil
      end

      it 'does not assign non_serviced_vehicles' do
        non_serviced_vehicle = create(:vehicle, customer: customer)
        service_type = create(:service_type, customer: customer)
        fake_vehicle_service = Faker.new([non_serviced_vehicle])
        controller.load_vehicle_service(fake_vehicle_service)

        get :show, {:id => service_type.to_param}, {}

        assigns(:non_serviced_vehicles).should be_nil
      end
    end
  end

  describe 'GET #new' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns a new service_type' do
        get :new, {}, {}
        assigns(:service_type).should be_a_new(ServiceType)
      end

      it 'assigns @interval_dates' do
        get :new, {}, {}

        assigns(:interval_dates).should include(Interval::FIVE_YEARS)
        assigns(:interval_dates).should_not include(Interval::NOT_REQUIRED)
      end

      it 'assigns @interval_mileages' do
        get :new, {}, {}

        assigns(:interval_mileages).should eq(ServiceType::INTERVAL_MILEAGES)
      end

      it 'assigns @expiration_types' do
        get :new, {}, {}

        assigns(:expiration_types).should eq(ServiceType::EXPIRATION_TYPES)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns a new service_type as @service_type' do
        get :new, {}, {}
        assigns(:service_type).should be_a_new(ServiceType)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service_type' do
        get :new, {}, {}
        assigns(:service_type).should be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      describe 'with valid params' do
        it 'calls service_type_service' do

          controller.load_service_type_service(fake_service_type_service)

          post :create, {:service_type => service_type_attributes}, {}

          fake_service_type_service.received_message.should == :create_service_type
        end

        it 'assigns a newly created service_type as @service_type' do
          controller.load_service_type_service(fake_service_type_service)

          post :create, {:service_type => service_type_attributes}, {}

          assigns(:service_type).should be_a(ServiceType)
        end

        it 'redirects to the created service_type' do
          controller.load_service_type_service(fake_service_type_service)

          post :create, {:service_type => service_type_attributes}, {}

          response.should redirect_to(ServiceType.last)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved service_type as @service_type' do
          controller.load_service_type_service(fake_service_type_service_non_persisted)

          post :create, {:service_type => {'name' => 'invalid value'}}, {}

          assigns(:service_type).should be_a_new(ServiceType)
        end

        it "re-renders the 'new' template" do
          controller.load_service_type_service(fake_service_type_service_non_persisted)

          post :create, {:service_type => {'name' => 'invalid value'}}, {}

          response.should render_template('new')
        end

        it 'assigns @interval_dates' do
          controller.load_service_type_service(fake_service_type_service_non_persisted)

          post :create, {:service_type => {'name' => 'invalid value'}}, {}

          assigns(:interval_dates).should include(Interval::FIVE_YEARS)
          assigns(:interval_dates).should_not include(Interval::NOT_REQUIRED)
        end

        it 'assigns @interval_mileages' do
          controller.load_service_type_service(fake_service_type_service_non_persisted)

          post :create, {:service_type => {'name' => 'invalid value'}}, {}

          assigns(:interval_mileages).should eq(ServiceType::INTERVAL_MILEAGES)
        end

        it 'assigns @expiration_types' do
          controller.load_service_type_service(fake_service_type_service_non_persisted)

          post :create, {:service_type => {'name' => 'invalid value'}}, {}

          assigns(:expiration_types).should eq(ServiceType::EXPIRATION_TYPES)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      let (:fake_service_type_service_non_persisted) { Faker.new(build(:service_type)) }

      it 'calls service_type_service' do
        controller.load_service_type_service(fake_service_type_service_non_persisted)

        post :create, {:service_type => service_type_attributes}, {}

        fake_service_type_service_non_persisted.received_message.should == :create_service_type
      end

      it 'assigns a newly created service_type as @service_type' do
        controller.load_service_type_service(fake_service_type_service_non_persisted)

        post :create, {:service_type => service_type_attributes}, {}

        assigns(:service_type).should be_a(ServiceType)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service_type as @service_type' do
        expect {
          post :create, {:service_type => service_type_attributes}, {}
        }.not_to change(ServiceType, :count)

        assigns(:service_type).should be_nil
        assigns(:interval_dates).should be_nil
        assigns(:interval_mileages).should be_nil
        assigns(:expiration_types).should be_nil
      end
    end
  end

  describe 'GET #edit' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns the requested service_type as @service_type' do
        service_type = create(:service_type, customer: customer)

        get :edit, {:id => service_type.to_param}, {}

        assigns(:service_type).should eq(service_type)
      end

      it 'assigns @interval_dates' do
        service_type = create(:service_type, customer: customer)

        get :edit, {:id => service_type.to_param}, {}

        assigns(:interval_dates).should include(Interval::FIVE_YEARS)
        assigns(:interval_dates).should_not include(Interval::NOT_REQUIRED)
      end

      it 'assigns @interval_mileages' do
        service_type = create(:service_type, customer: customer)

        get :edit, {:id => service_type.to_param}, {}

        assigns(:interval_mileages).should eq(ServiceType::INTERVAL_MILEAGES)
      end

      it 'assigns @expiration_types' do
        service_type = create(:service_type, customer: customer)

        get :edit, {:id => service_type.to_param}, {}

        assigns(:expiration_types).should eq(ServiceType::EXPIRATION_TYPES)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns the requested service_type as @service_type' do
        service_type = create(:service_type, customer: customer)

        get :edit, {:id => service_type.to_param}, {}

        assigns(:service_type).should eq(service_type)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service_type as @service_type' do
        service_type = create(:service_type, customer: customer)

        get :edit, {:id => service_type.to_param}, {}

        assigns(:service_type).should be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'when service_type user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested service_type' do
          service_type = create(:service_type, customer: customer)
          controller.load_service_type_service(fake_service_type_service)

          put :update, {:id => service_type.to_param, :service_type => {'name' => 'Box Check'}}, {}

          fake_service_type_service.received_message.should == :update_service_type
        end

        it 'assigns the requested service_type as @service_type' do
          controller.load_service_type_service(fake_service_type_service)
          service_type = create(:service_type, customer: customer)

          put :update, {:id => service_type.to_param, :service_type => service_type_attributes}, {}

          assigns(:service_type).should eq(service_type)
        end

        it 'redirects to the service_type' do
          controller.load_service_type_service(fake_service_type_service)
          service_type = create(:service_type, customer: customer)

          put :update, {:id => service_type.to_param, :service_type => service_type_attributes}, {}

          response.should redirect_to(service_type)
        end
      end

      describe 'with invalid params' do
        it 'assigns the service_type as @service_type' do
          controller.load_service_type_service(fake_service_type_service)
          service_type = create(:service_type, customer: customer)

          put :update, {:id => service_type.to_param, :service_type => {'name' => 'invalid value'}}, {}

          assigns(:service_type).should eq(service_type)
        end

        it "re-renders the 'edit' template" do
          controller.load_service_type_service(Faker.new(false))
          service_type = create(:service_type, customer: customer)

          put :update, {:id => service_type.to_param, :service_type => {'name' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns @interval_dates' do
          controller.load_service_type_service(Faker.new(false))
          service_type = create(:service_type, customer: customer)

          put :update, {:id => service_type.to_param, :service_type => {'name' => 'invalid value'}}, {}

          assigns(:interval_dates).should include(Interval::FIVE_YEARS)
          assigns(:interval_dates).should_not include(Interval::NOT_REQUIRED)
        end

        it 'assigns @interval_mileages' do
          controller.load_service_type_service(Faker.new(false))
          service_type = create(:service_type, customer: customer)

          put :update, {:id => service_type.to_param, :service_type => {'name' => 'invalid value'}}, {}

          assigns(:interval_mileages).should eq(ServiceType::INTERVAL_MILEAGES)
        end

        it 'assigns @expiration_types' do
          controller.load_service_type_service(Faker.new(false))
          service_type = create(:service_type, customer: customer)

          put :update, {:id => service_type.to_param, :service_type => {'name' => 'invalid value'}}, {}

          assigns(:expiration_types).should eq(ServiceType::EXPIRATION_TYPES)
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'updates the requested service_type' do
        controller.load_service_type_service(fake_service_type_service)
        service_type = create(:service_type, customer: customer)

        put :update, {:id => service_type.to_param, :service_type => {'name' => 'Box Check'}}, {}

        fake_service_type_service.received_message.should == :update_service_type
      end

      it 'assigns the requested service_type as @service_type' do
        controller.load_service_type_service(fake_service_type_service)
        service_type = create(:service_type, customer: customer)

        put :update, {:id => service_type.to_param, :service_type => service_type_attributes}, {}

        assigns(:service_type).should eq(service_type)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service_type as @service_type' do
        service_type = create(:service_type, customer: customer)

        put :update, {:id => service_type.to_param, :service_type => service_type_attributes}, {}

        assigns(:service_type).should be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'calls service_type_service' do
        controller.load_service_type_service(fake_service_type_service)
        service_type = create(:service_type, customer: customer)

        delete :destroy, {:id => service_type.to_param}, {}

        fake_service_type_service.received_message.should == :delete_service_type
      end

      it 'redirects to the service_type list' do
        controller.load_service_type_service(fake_service_type_service)
        service_type = create(:service_type, customer: customer)

        delete :destroy, {:id => service_type.to_param}, {}

        response.should redirect_to(service_types_path)
      end

      xit 'gives error message when vehicles exists' do
        service_type = create(:service_type, customer: customer)
        controller.load_service_type_service(Faker.new(:vehicle_exists))

        delete :destroy, {:id => service_type.to_param}, {}

        response.should redirect_to(service_type_url)
        flash[:notice].should == 'This Service Type is assigned to existing Vehicle(s).  You must remove the service from the Vehicles(s) before removing it.'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'calls service_type_service' do
        controller.load_service_type_service(fake_service_type_service)
        service_type = create(:service_type, customer: customer)

        delete :destroy, {:id => service_type.to_param}, {}

        fake_service_type_service.received_message.should == :delete_service_type
      end
    end
  end

  def service_type_attributes
    {
      name: 'Routine Inspection',
      expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
      interval_date: Interval::ONE_YEAR.text
    }
  end
end
