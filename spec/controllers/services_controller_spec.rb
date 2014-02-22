require 'spec_helper'

describe ServicesController do

  let(:customer) { create(:customer) }
  let(:service) { build(:service, customer: customer) }
  let(:fake_vehicle_servicing_service_that_returns_list) { Faker.new([service]) }
  let(:faker_that_returns_empty_list) { Faker.new([]) }

  describe 'GET #new' do
    context 'when service user' do
      let (:current_user) { stub_vehicle_user(customer) }

      before do
        sign_in current_user
      end

      it 'calls service with vehicle_id' do
        controller.load_service_type_service(Faker.new)
        vehicle = create(:vehicle)
        service = create(:service, vehicle: vehicle, customer: vehicle.customer)
        fake_vehicle_servicing_service = controller.load_vehicle_servicing_service(Faker.new(service))

        get :new, {vehicle_id: vehicle.id}, {}

        fake_vehicle_servicing_service.received_message.should == :new_vehicle_service
        fake_vehicle_servicing_service.received_params[0].should == current_user
        fake_vehicle_servicing_service.received_params[1].should == vehicle.id.to_s
      end

      it 'calls service with service_type_id' do
        controller.load_service_type_service(Faker.new)
        service_type = create(:service_type)
        service = create(:service, service_type: service_type, customer: service_type.customer)
        fake_vehicle_servicing_service = controller.load_vehicle_servicing_service(Faker.new(service))

        get :new, {service_type_id: service_type.id}, {}

        fake_vehicle_servicing_service.received_message.should == :new_vehicle_service
        fake_vehicle_servicing_service.received_params[0].should == current_user
        fake_vehicle_servicing_service.received_params[1].should == nil
        fake_vehicle_servicing_service.received_params[2].should == service_type.id.to_s
      end

      it 'assigns @service' do
        controller.load_service_type_service(Faker.new)
        service = create(:service, customer: create(:customer))
        controller.load_vehicle_servicing_service(Faker.new(service))

        get :new, {}, {}

        assigns(:service).should == service
      end

      it 'assigns @source when vehicle' do
        controller.load_vehicle_servicing_service(Faker.new)
        service_type = create(:service_type)
        controller.load_service_type_service(Faker.new([service_type]))

        get :new, {source: 'vehicle'}, {}

        assigns(:source).should eq('vehicle')
      end

      it 'assigns @source when service_type' do
        controller.load_vehicle_servicing_service(Faker.new)
        service_type = create(:service_type)
        controller.load_service_type_service(Faker.new([service_type]))

        get :new, {source: 'service_type'}, {}

        assigns(:source).should eq('service_type')
      end

      it 'calls service_type_service' do
        controller.load_vehicle_servicing_service(Faker.new)
        fake_service_type_service = controller.load_service_type_service(faker_that_returns_empty_list)

        get :new, {}, {}

        fake_service_type_service.received_message.should == :get_all_service_types
        fake_service_type_service.received_params[0].should == current_user
      end

      it 'assigns service_types' do
        controller.load_vehicle_servicing_service(Faker.new)
        service_type = create(:service_type)
        controller.load_service_type_service(Faker.new([service_type]))

        get :new, {}, {}

        assigns(:service_types).map(&:model).should eq([service_type])
      end

      it 'assigns vehicles' do
        controller.load_vehicle_servicing_service(Faker.new)
        vehicle = create(:vehicle)
        controller.load_vehicle_service(Faker.new([vehicle]))

        get :new, {}, {}

        assigns(:vehicles).map(&:model).should eq([vehicle])
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns service_types' do
        service_type = build(:service_type)
        controller.load_service_type_service(Faker.new([service_type]))
        controller.load_vehicle_servicing_service(Faker.new)

        get :new, {}, {}

        assigns(:service_types).map(&:model).should eq([service_type])
      end

      it 'assigns vehicles' do
        controller.load_vehicle_servicing_service(Faker.new)
        vehicle = create(:vehicle)
        controller.load_vehicle_service(Faker.new([vehicle]))

        get :new, {}, {}

        assigns(:vehicles).map(&:model).should eq([vehicle])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service_types' do
        get :new, {}, {}
        assigns(:service_types).should be_nil
      end

      it 'does not assign vehicles' do
        get :new, {}, {}
        assigns(:vehicles).should be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'when service user' do
      let (:current_user) { stub_vehicle_user(customer) }
      before do
        sign_in current_user
      end

      it 'calls creates service using vehicle_servicing_service' do
        fake_vehicle_servicing_service = controller.load_vehicle_servicing_service(Faker.new(build(:service)))

        params = {
          service: {
            vehicle_id: 99,
            service_type_id: 1001,
            last_service_date: '3/3/2003',
            last_service_mileage: '3100',
            comments: 'comments'
          },
          source: :vehicle,
          commit: "Create"
        }

        post :create, params, {}

        fake_vehicle_servicing_service.received_message.should == :service_vehicle
        fake_vehicle_servicing_service.received_params[0].should == current_user
        fake_vehicle_servicing_service.received_params[1].should == '99'
        fake_vehicle_servicing_service.received_params[2].should == '1001'
        fake_vehicle_servicing_service.received_params[3].should == '3/3/2003'
        fake_vehicle_servicing_service.received_params[4].should == '3100'
        fake_vehicle_servicing_service.received_params[5].should == 'comments'
      end

      it 're-renders new on error' do
        controller.load_service_type_service(Faker.new([build(:service_type)]))
        service = build(:service)
        service.stub(:valid?).and_return(false)
        controller.load_vehicle_servicing_service(Faker.new(service))

        post :create, {vehicle: {}, service: {}}, {}

        response.should render_template('new')
      end

      it 'assigns @service on error' do
        controller.load_service_type_service(Faker.new)
        service = build(:service)
        service.stub(:valid?).and_return(false)
        controller.load_vehicle_servicing_service(Faker.new(service))

        get :create, {service: {vehicle_id: 1, service_type_id: 1}}, {}

        assigns(:service).should == service
      end

      it 'calls service_type_service on error' do
        service = build(:service)
        service.stub(:valid?).and_return(false)
        controller.load_vehicle_servicing_service(Faker.new(service))
        service_type = create(:service_type)
        fake_service_type_service = controller.load_service_type_service(Faker.new([service_type]))

        get :create, {vehicle: {}, service: {}}, {}

        fake_service_type_service.received_message.should == :get_all_service_types
        fake_service_type_service.received_params[0].should == current_user
      end

      it 'assigns service_types on error' do
        service = build(:service)
        service.stub(:valid?).and_return(false)
        controller.load_vehicle_servicing_service(Faker.new(service))
        service_type = create(:service_type)
        controller.load_service_type_service(Faker.new([service_type]))

        get :create, {vehicle: {}, service: {}}, {}

        assigns(:service_types).map(&:model).should eq([service_type])
      end

      it 'assigns vehicles on error' do
        service = build(:service)
        service.stub(:valid?).and_return(false)
        controller.load_vehicle_servicing_service(Faker.new(service))
        vehicle = create(:vehicle)
        controller.load_vehicle_service(Faker.new([vehicle]))

        get :create, {vehicle: {}, service: {}}, {}

        assigns(:vehicles).map(&:model).should eq([vehicle])
      end

      it 'handles missing vehicle_id' do
        service = build(:service)
        service.stub(:valid?).and_return(false)
        controller.load_vehicle_servicing_service(Faker.new(service))

        params = {
          vehicle: {id: nil},
          service: {}
        }

        post :create, params, {}

        response.should render_template('new')
      end

      context 'Create' do
        it 'redirects to show vehicle page on success when source is :vehicle' do
          vehicle = create(:vehicle)
          service_type = create(:service_type)
          service = create(:service, vehicle: vehicle, service_type: service_type, customer: vehicle.customer)

          controller.load_vehicle_servicing_service(Faker.new(service))

          params = {
            service: {
              vehicle_id: 1,
              service_type_id: 1
            },
            source: :vehicle,
            commit: 'Create'
          }

          post :create, params, {}

          response.should redirect_to(vehicle)
        end

        it 'redirects to show service type page on success when source is :service_type' do
          vehicle = create(:vehicle)
          service_type = create(:service_type)
          service = create(:service, vehicle: vehicle, service_type: service_type, customer: vehicle.customer)

          controller.load_vehicle_servicing_service(Faker.new(service))

          params = {
            service: {
              vehicle_id: 1,
              service_type_id: 1
            },
            source: :service_type,
            commit: 'Create'
          }

          post :create, params, {}

          response.should redirect_to(service_type)
        end

        it 'redirects to show service type page on success when source is :service' do
          vehicle = create(:vehicle)
          service_type = create(:service_type)
          service = create(:service, vehicle: vehicle, service_type: service_type, customer: vehicle.customer)

          controller.load_vehicle_servicing_service(Faker.new(service))

          params = {
            service: {
              vehicle_id: 1,
              service_type_id: 1
            },
            source: :service,
            commit: 'Create'
          }

          post :create, params, {}

          response.should redirect_to(service_type)
        end

        it 'gives successful message on success' do
          vehicle = create(
            :vehicle,
            license_plate: 'PLATE',
            year: 2011,
            vehicle_model: 'Dart',
            vehicle_number: 'DD123'
          )
          service_type = create(:service_type, name: 'certType24')
          service = create(:service, vehicle: vehicle, service_type: service_type, customer: vehicle.customer)

          controller.load_vehicle_servicing_service(Faker.new(service))

          params = {
            service: {
              vehicle_id: 1,
              service_type_id: 1
            },
            commit: 'Create'
          }

          post :create, params, {}

          flash[:notice].should == 'Service: certType24 created for Vehicle PLATE/DD123 2011 Dart.'
        end
      end

      context 'Save and Create Another' do
        it 'calls service_type_service on success' do
          controller.load_vehicle_servicing_service(Faker.new(build(:service)))
          fake_service_type_service = controller.load_service_type_service(faker_that_returns_empty_list)

          params = {
            vehicle: {},
            service: {},
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          fake_service_type_service.received_message.should == :get_all_service_types
          fake_service_type_service.received_params[0].should == current_user
        end

        it 'assigns service, vehicles and service_types on success' do
          controller.load_vehicle_servicing_service(Faker.new(build(:service)))
          service_type = create(:service_type)
          controller.load_service_type_service(Faker.new([service_type]))
          vehicle = create(:vehicle)
          controller.load_vehicle_service(Faker.new([vehicle]))

          params = {
            service: {
              vehicle_id: 1,
              service_type_id: 1
            },
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          assigns(:service).should be_a(Service)
          assigns(:service_types).map(&:model).should eq([service_type])
          assigns(:vehicles).map(&:model).should eq([vehicle])
        end

        it 'renders create service on success' do
          controller.load_vehicle_servicing_service(Faker.new(build(:service)))
          controller.load_service_type_service(Faker.new)

          params = {
            vehicle: {},
            service: {},
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          response.should render_template('new')
        end

        it 'gives successful message on success' do
          vehicle = create(
            :vehicle,
            license_plate: 'PLATE',
            year: 2011,
            vehicle_model: 'Dart',
            vehicle_number: 'DD123'
          )

          service_type = create(:service_type, name: 'certType24')
          service = create(:service, vehicle: vehicle, service_type: service_type, customer: vehicle.customer)

          controller.load_vehicle_servicing_service(Faker.new(service))
          controller.load_service_type_service(faker_that_returns_empty_list)

          params = {
            service: {
              vehicle_id: 1,
              service_type_id: 1
            },
            commit: 'Save and Create Another'
          }

          post :create, params, {}

          flash[:notice].should == "Service: certType24 created for Vehicle PLATE/DD123 2011 Dart."
        end
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not call factory' do
        fake_vehicle_servicing_service = controller.load_vehicle_servicing_service(Faker.new)

        post :create, {}, {}

        fake_vehicle_servicing_service.received_message.should be_nil
      end
    end
  end

  describe 'GET #show' do
    context 'when vehicle user' do
      let (:current_user) { stub_vehicle_user(customer) }

      before do
        sign_in current_user
      end

      it 'assigns service' do
        service = create(:service, customer: customer)

        get :show, {:id => service.to_param}, {}

        assigns(:service).should eq(service)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns service' do
        service = create(:service, customer: customer)

        get :show, {:id => service.to_param}, {}

        assigns(:service).should eq(service)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service' do
        service = create(:service, customer: customer)

        get :show, {:id => service.to_param}, {}

        assigns(:service).should be_nil
      end
    end
  end

  describe 'GET #edit' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns the requested service as @service' do
        service = create(:service, customer: customer)
        get :edit, {:id => service.to_param}, {}
        assigns(:service).should eq(service)
      end

      it 'assigns service_types' do
        service = create(:service, customer: customer)
        controller.load_vehicle_servicing_service(Faker.new)
        service_type = create(:service_type)
        controller.load_service_type_service(Faker.new([service_type]))

        get :edit, {:id => service.to_param}, {}

        assigns(:service_types).map(&:model).should eq([service_type])
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns the requested service as @service' do
        service = create(:service, customer: customer)
        get :edit, {:id => service.to_param}, {}
        assigns(:service).should eq(service)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service as @service' do
        service = create(:service, customer: customer)
        get :edit, {:id => service.to_param}, {}
        assigns(:service).should be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested service' do
          service = create(:service, customer: customer)
          new_service_type = create(:service_type, customer: customer)
          fake_service_service = Faker.new(service)
          controller.load_vehicle_servicing_service(fake_service_service)

          put :update, {:id => service.to_param, :service =>
            {
              'service_type_id' => new_service_type.id,
              'last_service_date' => '01/01/2001',
              'last_service_mileage' => '10000',
              'comments' => 'some new notes'
            }
          }, {}

          fake_service_service.received_message.should == :update_service
          fake_service_service.received_params[0].should == service
          fake_service_service.received_params[1][:service_type_id].should == new_service_type.id.to_s
          fake_service_service.received_params[1][:last_service_date].should == '01/01/2001'
          fake_service_service.received_params[1][:last_service_mileage].should == '10000'
          fake_service_service.received_params[1][:comments].should == 'some new notes'
        end

        it 'assigns the requested service' do
          controller.load_vehicle_servicing_service(Faker.new(true))
          service = create(:service, customer: customer)

          put :update, {:id => service.to_param, :service => {'comments' => 'Test'}}, {}

          assigns(:service).should eq(service)
        end

        it 'redirects to the show service type page' do
          controller.load_vehicle_servicing_service(Faker.new(true))
          service = create(:service, customer: customer)

          put :update, {:id => service.to_param, :service => {'comments' => 'Test'}}, {}

          response.should redirect_to(service.service_type)
          flash[:notice].should == 'Service was successfully updated.'
        end
      end

      describe 'with invalid params' do
        it 'assigns the service' do
          controller.load_vehicle_servicing_service(Faker.new(false))
          service = create(:service, customer: customer)

          put :update, {:id => service.to_param, :service => {'comments' => 'invalid value'}}, {}

          assigns(:service).should eq(service)
        end

        it "re-renders the 'edit' template" do
          controller.load_vehicle_servicing_service(Faker.new(false))
          service = create(:service, customer: customer)

          put :update, {:id => service.to_param, :service => {'comments' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns @service_types' do
          service = create(:service, customer: customer)
          controller.load_vehicle_servicing_service(Faker.new(false))
          service_type = create(:service_type)
          controller.load_service_type_service(Faker.new([service_type]))

          put :update, {:id => service.to_param, :service => {'comments' => 'invalid value'}}, {}

          assigns(:service_types).map(&:model).should eq([service_type])
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'updates the requested service' do
        fake_service_service = Faker.new(true)
        controller.load_vehicle_servicing_service(fake_service_service)
        service = create(:service, customer: customer)

        put :update, {:id => service.to_param, :service =>
          {
            'last_service_date' => '01/01/2001'
          }
        }, {}

        fake_service_service.received_message.should == :update_service
      end

      it 'assigns the requested service as @service' do
        service = create(:service, customer: customer)
        controller.load_vehicle_servicing_service(Faker.new(service))

        put :update, {:id => service.to_param, :service => {'comments' => 'Test'}}, {}

        assigns(:service).should eq(service)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service' do
        service = create(:service, customer: customer)

        put :update, {:id => service.to_param, :service => {'comments' => 'Test'}}, {}

        assigns(:service).should be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'calls VehicleServicingService' do
        fake_service_service = Faker.new
        controller.load_vehicle_servicing_service(fake_service_service)
        service = create(:service, customer: customer)

        delete :destroy, {:id => service.to_param}, {}

        fake_service_service.received_message.should == :delete_service
      end

      it 'redirects to the show service type page' do
        service = create(:service, customer: customer)
        controller.load_vehicle_servicing_service(Faker.new)

        delete :destroy, {:id => service.to_param}, {}

        response.should redirect_to(service.service_type)
      end

      it 'displays the success message' do
        vehicle = create(
          :vehicle,
          license_plate: 'ABC-123',
          vehicle_number: 'JB3',
          make: 'Jeep',
          vehicle_model: 'Wrangler'
        )
        service_type = create(:service_type, name: 'AAA Truck Inspection')
        service = create(:service, service_type: service_type, vehicle: vehicle, customer: customer)
        controller.load_vehicle_servicing_service(Faker.new)

        delete :destroy, {:id => service.to_param}, {}

        flash[:notice].should == 'Service AAA Truck Inspection for Vehicle ABC-123/JB3 2010 Wrangler deleted.'
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls VehicleServicingService' do
        fake_service_service = Faker.new
        controller.load_vehicle_servicing_service(fake_service_service)
        service = create(:service, customer: customer)

        delete :destroy, {:id => service.to_param}, {}

        fake_service_service.received_message.should == :delete_service
      end
    end
  end

  describe 'GET #service_history' do
    context 'when vehicle user' do
      let (:current_user) { stub_vehicle_user(customer) }

      before do
        sign_in current_user
      end

      it 'assigns services presenter as @service' do
        service = create(:service, customer: customer)
        get :service_history, {:id => service.to_param}, {}
        assigns(:service).should eq(service)
      end

      it 'assigns service_periods as @service_periods' do
        service_period = create(:service_period)
        service = create(:service, customer: customer, active_service_period: service_period)
        get :service_history, {:id => service.to_param}, {}
        assigns(:service_periods).map(&:model).should eq([service_period])
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin(customer)
      end

      it 'assigns service presenter as @service' do
        service = create(:service, customer: customer)
        get :service_history, {:id => service.to_param}, {}
        assigns(:service).should eq(service)
      end

      it 'assigns service_periods as @service_periods' do
        service_period = create(:service_period)
        service = create(:service, customer: customer, active_service_period: service_period)
        get :service_history, {:id => service.to_param}, {}
        assigns(:service_periods).map(&:model).should eq([service_period])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign service presenter as @service' do
        service = create(:service, customer: customer)
        get :service_history, {:id => service.to_param}, {}
        assigns(:service).should be_nil
      end

      it 'does not assign service_periods as @service_periods' do
        service_period = create(:service_period)
        service = create(:service, customer: customer, active_service_period: service_period)
        get :service_history, {:id => service.to_param}, {}
        assigns(:service_periods).should be_nil
      end
    end
  end

  describe 'GET #index' do
    it 'calls get_all_services with current_user and params' do
      my_user = stub_vehicle_user(customer)
      sign_in my_user
      fake_vehicle_servicing_service = controller.load_vehicle_servicing_service(faker_that_returns_empty_list)
      fake_service_list_presenter = Faker.new([])
      ServiceListPresenter.stub(:new).and_return(fake_service_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :index, params

      fake_vehicle_servicing_service.received_messages.should == [:get_all_services]
      fake_vehicle_servicing_service.received_params[0].should == my_user

      fake_service_list_presenter.received_message.should == :present
      fake_service_list_presenter.received_params[0]['sort'].should == 'name'
      fake_service_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns services' do
        controller.load_vehicle_servicing_service(fake_vehicle_servicing_service_that_returns_list)

        get :index

        assigns(:services).map(&:model).should eq([service])
      end

      it 'assigns service_count' do
        big_list_of_services = []
        30.times do
          big_list_of_services << create(:service)
        end
        controller.load_vehicle_servicing_service(Faker.new(big_list_of_services))
        params = {per_page: 25, page: 1}

        get :index, params

        assigns(:service_count).should eq(30)
      end

      it 'assigns report_title' do
        controller.load_vehicle_servicing_service(faker_that_returns_empty_list)

        get :index

        assigns(:report_title).should eq('All Vehicle Services')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns services' do
        controller.load_vehicle_servicing_service(fake_vehicle_servicing_service_that_returns_list)

        get :index

        assigns(:services).map(&:model).should eq([service])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign services' do
          get :index

          assigns(:services).should be_nil
        end
      end
    end
  end
  
  describe 'GET #expired' do
    it 'calls get_expired with current_user and params' do
      my_user = stub_vehicle_user(customer)
      sign_in my_user
      fake_vehicle_servicing_service = controller.load_vehicle_servicing_service(Faker.new([]))
      fake_service_list_presenter = Faker.new([])
      ServiceListPresenter.stub(:new).and_return(fake_service_list_presenter)
      params = {sort: 'name', direction: 'asc'}

      get :expired, params

      fake_vehicle_servicing_service.received_messages.should == [:get_expired_services]
      fake_vehicle_servicing_service.received_params[0].should == my_user

      fake_service_list_presenter.received_message.should == :present
      fake_service_list_presenter.received_params[0]['sort'].should == 'name'
      fake_service_list_presenter.received_params[0]['direction'].should == 'asc'
    end

    context 'when certification user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns services' do
        service = create(:service, customer: customer)

        controller.load_vehicle_servicing_service(Faker.new([service]))

        get :expired

        assigns(:services).map(&:model).should eq([service])
      end

      it 'assigns services_count' do
        big_list_of_services = []
        30.times do
          big_list_of_services << create(:service)
        end

        controller.load_vehicle_servicing_service(Faker.new(big_list_of_services))

        get :expired, {per_page: 25, page: 1}

        assigns(:service_count).should eq(30)
      end

      it 'assigns report_title' do
        controller.load_vehicle_servicing_service(Faker.new([]))

        get :expired

        assigns(:report_title).should eq('Expired Vehicle Services')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns services' do
        service = create(:service, customer: customer)

        controller.load_vehicle_servicing_service(Faker.new([service]))

        get :expired

        assigns(:services).map(&:model).should eq([service])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET expired' do
        it 'does not assign services' do
          get :expired

          assigns(:services).should be_nil
        end
      end
    end
  end
end