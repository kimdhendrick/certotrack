require 'spec_helper'

describe ServicesController do

  let(:customer) { create(:customer) }
  let(:service) { build(:service) }
  let(:fake_vehicle_servicing_service_that_returns_list) { Faker.new([service]) }
  let(:faker_that_returns_empty_list) { Faker.new([]) }

  describe 'GET new' do
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

  describe 'POST create' do
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

          flash[:notice].should == "Service: certType24 created for Vehicle PLATE/DD123 2011 Dart."
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
end