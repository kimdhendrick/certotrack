require 'spec_helper'

describe VehiclesController do
  let(:customer) { build(:customer) }
  let(:vehicle) { build(:vehicle) }

  describe 'GET index' do
    context 'when vehicle user' do
      before do
        @my_user = stub_vehicle_user(customer)
        sign_in @my_user
      end

      it 'calls get_all_vehicles with current_user and params' do
        fake_vehicle_service = controller.load_vehicle_service(Faker.new([]))

        get :index, {}

        fake_vehicle_service.received_messages.should == [:get_all_vehicles]
        fake_vehicle_service.received_params[0].should == @my_user
      end

      it 'presents vehicles with VehicleListPresenter' do
        controller.load_vehicle_service(Faker.new([]))
        fake_vehicle_list_presenter = Faker.new([])
        VehicleListPresenter.stub(:new).and_return(fake_vehicle_list_presenter)
        params = {sort: 'name', direction: 'asc'}

        get :index, params

        fake_vehicle_list_presenter.received_message.should == :present
        fake_vehicle_list_presenter.received_params[0]['sort'].should == 'name'
        fake_vehicle_list_presenter.received_params[0]['direction'].should == 'asc'
      end

      it 'assigns vehicles' do
        controller.load_vehicle_service(Faker.new([vehicle]))

        get :index

        assigns(:vehicles).map(&:model).should eq([vehicle])
      end

      it 'assigns vehicle_count' do
        big_list_of_vehicles = []
        30.times do
          big_list_of_vehicles << create(:vehicle)
        end

        controller.load_vehicle_service(Faker.new(big_list_of_vehicles))

        get :index, {per_page: 25, page: 1}

        assigns(:vehicle_count).should eq(30)
      end

      it 'assigns report_title' do
        get :index

        assigns(:report_title).should eq('All Vehicles')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
        controller.load_vehicle_service(Faker.new([vehicle]))
      end

      it 'assigns vehicles' do
        get :index

        assigns(:vehicles).map(&:model).should eq([vehicle])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign vehicles' do
          get :index

          assigns(:vehicles).should be_nil
        end
      end
    end
  end

  describe 'GET new' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns a new vehicle' do

        get :new, {}, {}

        assigns(:vehicle).should be_a_new(Vehicle)
      end

      it 'assigns a sorted list of locations to @locations' do
        location = build(:location)
        fake_location_service = Faker.new([location])
        controller.load_location_service(fake_location_service)
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)

        get :new, {}, {}

        assigns(:locations).should == [location]
        fake_location_list_presenter.received_message.should == :sort
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns a new vehicle' do
        get :new, {}, {}

        assigns(:vehicle).should be_a_new(Vehicle)
      end

      it 'assigns a sorted list of locations to @locations' do
        location = build(:location)
        fake_location_service = Faker.new([location])
        controller.load_location_service(fake_location_service)
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)

        get :new, {}, {}

        assigns(:locations).should == [location]
        fake_location_list_presenter.received_message.should == :sort
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign vehicle' do
        get :new, {}, {}

        assigns(:vehicle).should be_nil
      end

      it 'does not assign a list of locations' do
        get :new, {}, {}

        assigns(:locations).should be_nil
      end
    end
  end

  describe 'POST create' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      describe 'with valid params' do
        it 'creates a new vehicle' do
          fake_vehicle_service = Faker.new(build(:vehicle))
          controller.load_vehicle_service(fake_vehicle_service)

          post :create, {:vehicle => {vin: '98765432109876543'}}, {}

          fake_vehicle_service.received_message.should == :create_vehicle
        end

        it 'assigns a newly created vehicle' do
          controller.load_vehicle_service(Faker.new(build(:vehicle)))

          post :create, {:vehicle => {vin: '98765432109876543'}}, {}

          assigns(:vehicle).should be_a(Vehicle)
        end

        it 'redirects to the created vehicle' do
          vehicle = create(:vehicle, vehicle_number: 'vehicle_number')
          controller.load_vehicle_service(Faker.new(vehicle))

          post :create, {:vehicle => {vin: '98765432109876543'}}, {}

          response.should redirect_to(Vehicle.last)
          flash[:success].should == "Vehicle number 'vehicle_number' was successfully created."
        end

        it 'sets the current_user as the creator' do
          fake_vehicle_service = Faker.new(build(:vehicle))
          controller.load_vehicle_service(fake_vehicle_service)

          post :create, {:vehicle => {vin: '98765432109876543'}}, {}

          fake_vehicle_service.received_params[1]['created_by'].should =~ /username/
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved vehicle' do
          fake_vehicle_service = Faker.new(build(:vehicle))
          controller.load_vehicle_service(fake_vehicle_service)

          post :create, {:vehicle => {'vin' => 'invalid value'}}, {}

          assigns(:vehicle).should be_a_new(Vehicle)
          fake_vehicle_service.received_message.should == :create_vehicle
        end

        it "re-renders the 'new' template" do
          controller.load_vehicle_service(Faker.new(build(:vehicle)))

          post :create, {:vehicle => {'vin' => 'invalid value'}}, {}

          response.should render_template('new')
        end

        it 'assigns a sorted list of locations to @locations' do
          location = build(:location)
          fake_location_service = Faker.new([location])
          controller.load_location_service(fake_location_service)
          fake_location_list_presenter = Faker.new([location])
          LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
          controller.load_vehicle_service(Faker.new(build(:vehicle)))

          post :create, {:vehicle => {'vin' => 'invalid value'}}, {}

          assigns(:locations).should == [location]
          fake_location_list_presenter.received_message.should == :sort
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls vehicle_service' do
        customer = create(:customer)
        fake_vehicle_service = Faker.new(build(:vehicle))
        controller.load_vehicle_service(fake_vehicle_service)

        post :create, {:vehicle => {vin: '123'}}, {}

        fake_vehicle_service.received_message.should == :create_vehicle
      end

      it 'assigns a newly created vehicle' do
        controller.load_vehicle_service(Faker.new(build(:vehicle)))

        post :create, {:vehicle => {vin: '123'}}, {}

        assigns(:vehicle).should be_a(Vehicle)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign vehicle' do
        expect {
          post :create, {:vehicle => {vin: '123'}}, {}
        }.not_to change(Vehicle, :count)
        assigns(:vehicle).should be_nil
      end
    end
  end

  describe 'GET show' do
    let(:vehicle) { create(:vehicle, customer: customer) }
    let(:vehicle_servicing_service) { double('vehicle_servicing_service') }
    let(:service) { create(:service, vehicle: vehicle, customer: customer) }
    let(:services) { [service] }

    before do
      controller.load_vehicle_servicing_service(vehicle_servicing_service)
      vehicle_servicing_service.stub(:get_all_services_for_vehicle).and_return(services)
    end

    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns vehicle' do
        get :show, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should eq(vehicle)
      end

      it 'assigns services' do
        get :show, {:id => vehicle.to_param}, {}

        assigns(:services).map(&:model).should == services
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns vehicle' do
        get :show, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should eq(vehicle)
      end

      it 'assigns services' do
        get :show, {:id => vehicle.to_param}, {}

        assigns(:services).map(&:model).should == services
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign vehicle' do
        vehicle = create(:vehicle, customer: customer)

        get :show, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should be_nil
      end
    end
  end

  describe 'GET edit' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns the requested vehicle' do
        vehicle = create(:vehicle, customer: customer)

        get :edit, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should eq(vehicle)
      end

      it 'assigns a sorted list of locations to @locations' do
        location = build(:location)
        fake_location_service = Faker.new([location])
        controller.load_location_service(fake_location_service)
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
        controller.load_vehicle_service(Faker.new(build(:vehicle)))
        vehicle = create(:vehicle, customer: customer)

        get :edit, {:id => vehicle.to_param}, {}

        assigns(:locations).should == [location]
        fake_location_list_presenter.received_message.should == :sort
      end
    end

    context 'when admin user' do
      let(:customer) { build(:customer) }
      let(:vehicle) { create(:vehicle, customer: customer) }

      before do
        sign_in stub_admin
      end

      it 'assigns the requested vehicle' do
        get :edit, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should eq(vehicle)
      end

      it 'assigns a sorted list of locations to @locations' do
        location = build(:location)
        fake_location_service = Faker.new([location])
        controller.load_location_service(fake_location_service)
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
        controller.load_vehicle_service(Faker.new(build(:vehicle)))
        vehicle = create(:vehicle, customer: customer)

        get :edit, {:id => vehicle.to_param}, {}

        assigns(:locations).should == [location]
        fake_location_list_presenter.received_message.should == :sort
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign vehicle' do
        vehicle = create(:vehicle, customer: customer)

        get :edit, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should be_nil
      end
    end
  end

  describe 'PUT update' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      describe 'with valid params' do
        it 'updates the requested vehicle' do
          vehicle = create(:vehicle, customer: customer)
          fake_vehicle_service = Faker.new(true)
          controller.load_vehicle_service(fake_vehicle_service)

          put :update, {:id => vehicle.to_param, :vehicle => {'vehicle_number' => '123'}}, {}

          fake_vehicle_service.received_message.should == :update_vehicle
          fake_vehicle_service.received_params[0].should == vehicle
          fake_vehicle_service.received_params[1].should == {'vehicle_number' => '123'}
        end

        it 'assigns the requested vehicle' do
          controller.load_vehicle_service(Faker.new(true))
          vehicle = create(:vehicle, customer: customer)

          put :update, {:id => vehicle.to_param, :vehicle => {'vehicle_number' => '123'}}, {}

          assigns(:vehicle).should eq(vehicle)
        end

        it 'redirects to the vehicle' do
          controller.load_vehicle_service(Faker.new(true))
          vehicle = create(:vehicle, vehicle_number: 'vehicle_number', customer: customer)

          put :update, {:id => vehicle.to_param, :vehicle => {'vehicle_number' => '123'}}, {}

          response.should redirect_to(vehicle)
          flash[:success].should == "Vehicle number 'vehicle_number' was successfully updated."
        end
      end

      describe 'with invalid params' do
        it 'assigns the vehicle' do
          controller.load_vehicle_service(Faker.new(false))
          vehicle = create(:vehicle, customer: customer)

          put :update, {:id => vehicle.to_param, :vehicle => {'vehicle_number' => 'invalid value'}}, {}

          assigns(:vehicle).should eq(vehicle)
        end

        it "re-renders the 'edit' template" do
          vehicle = create(:vehicle, customer: customer)
          controller.load_vehicle_service(Faker.new(false))

          put :update, {:id => vehicle.to_param, :vehicle => {'vehicle_number' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns a sorted list of locations to @locations' do
          location = build(:location)
          fake_location_service = Faker.new([location])
          controller.load_location_service(fake_location_service)
          fake_location_list_presenter = Faker.new([location])
          LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
          vehicle = create(:vehicle, customer: customer)
          controller.load_vehicle_service(Faker.new(false))

          put :update, {:id => vehicle.to_param, :vehicle => {'vehicle_number' => 'invalid value'}}, {}

          assigns(:locations).should == [location]
          fake_location_list_presenter.received_message.should == :sort
        end
      end

    end

    context 'when admin user' do
      let(:customer) { build(:customer) }
      let(:vehicle) { create(:vehicle, customer: customer) }

      before do
        sign_in stub_admin
      end

      it 'updates the requested vehicle' do
        fake_vehicle_service = Faker.new(true)
        controller.load_vehicle_service(fake_vehicle_service)
        put :update, {:id => vehicle.to_param, :vehicle => {'vehicle_number' => 'J123'}}, {}

        fake_vehicle_service.received_message.should == :update_vehicle
        fake_vehicle_service.received_params[0].should == vehicle
        fake_vehicle_service.received_params[1].should == {'vehicle_number' => 'J123'}
      end

      it 'assigns the requested vehicle' do
        controller.load_vehicle_service(Faker.new(vehicle))

        put :update, {:id => vehicle.id, :vehicle => {'vehicle_number' => '123'}}, {}

        assigns(:vehicle).should eq(vehicle)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign vehicle' do
        vehicle = create(:vehicle, customer: customer)

        put :update, {:id => vehicle.to_param, :vehicle => {'vehicle_number' => '123'}}, {}

        assigns(:vehicle).should be_nil
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'calls vehicle_service' do
        vehicle = create(:vehicle, customer: customer)
        fake_vehicle_service = Faker.new(true)
        controller.load_vehicle_service(fake_vehicle_service)

        delete :destroy, {:id => vehicle.to_param}, {}

        fake_vehicle_service.received_message.should == :delete_vehicle
        fake_vehicle_service.received_params[0].should == vehicle
      end

      context 'when destroy call succeeds' do
        before do
          vehicle = create(:vehicle, customer: customer)
          vehicle_service = double('vehicle_service')
          vehicle_service.stub(:delete_vehicle).and_return(true)
          controller.load_vehicle_service(vehicle_service)

          delete :destroy, {id: vehicle.to_param}, {}
        end

        it 'redirects to the vehicle list' do
          vehicle = create(:vehicle, vehicle_number: 'blah123', customer: customer)
          controller.load_vehicle_service(Faker.new(true))

          delete :destroy, {:id => vehicle.to_param}, {}

          response.should redirect_to(vehicles_path)
          flash[:success].should == "Vehicle number 'blah123' was successfully deleted."
        end
      end

      context 'when destroy call fails' do
        before do
          vehicle = create(:vehicle, customer: customer)
          vehicle_service = double('vehicle_service')
          vehicle_service.stub(:delete_vehicle).and_return(false)
          controller.load_vehicle_service(vehicle_service)

          delete :destroy, {id: vehicle.to_param}, {}
        end

        it 'should render show page' do
          response.should render_template('show')
        end

        it 'should assign services' do
          expect(assigns(:services)).to eq([])
        end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls vehicle_service' do
        vehicle = create(:vehicle, customer: customer)
        fake_vehicle_service = Faker.new(true)
        controller.load_vehicle_service(fake_vehicle_service)

        delete :destroy, {:id => vehicle.to_param}, {}

        fake_vehicle_service.received_message.should == :delete_vehicle
        fake_vehicle_service.received_params[0].should == vehicle
      end
    end
  end

  describe 'GET search' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'calls get_all_vehicles with current_user and params' do
        my_user = stub_vehicle_user(customer)
        sign_in my_user
        fake_vehicle_service = controller.load_vehicle_service(Faker.new([]))
        fake_vehicle_list_presenter = Faker.new([])
        VehicleListPresenter.stub(:new).and_return(fake_vehicle_list_presenter)

        get :search, {sort: 'name', direction: 'asc'}

        fake_vehicle_service.received_message.should == :search_vehicles
        fake_vehicle_service.received_params[0].should == my_user

        fake_vehicle_list_presenter.received_message.should == :present
        fake_vehicle_list_presenter.received_params[0]['sort'].should == 'name'
        fake_vehicle_list_presenter.received_params[0]['direction'].should == 'asc'
      end

      it 'assigns vehicles' do
        vehicle = build(:vehicle, customer: customer)
        fake_vehicle_service = Faker.new([vehicle])
        controller.load_vehicle_service(fake_vehicle_service)
        VehicleListPresenter.stub(:new).and_return(Faker.new([VehiclePresenter.new(vehicle)]))

        get :search

        assigns(:vehicles).map(&:model).should eq([vehicle])
        fake_vehicle_service.received_message.should == :search_vehicles
      end

      it 'assigns vehicle_count' do
        big_list_of_vehicles = []
        30.times do
          big_list_of_vehicles << create(:vehicle)
        end

        controller.load_vehicle_service(Faker.new(big_list_of_vehicles))

        get :search, {per_page: 25, page: 1}

        assigns(:vehicle_count).should eq(30)
      end

      it 'assigns report_title' do
        controller.load_vehicle_service(Faker.new([]))

        get :search

        assigns(:report_title).should eq('Search Vehicles')
      end

      it 'assigns sorted locations' do
        my_user = stub_vehicle_user(customer)
        sign_in my_user
        location = build(:location)
        fake_location_list_presenter = Faker.new([location])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
        fake_location_service = Faker.new([location])
        controller.load_location_service(fake_location_service)

        get :search

        fake_location_service.received_message.should == :get_all_locations
        fake_location_service.received_params[0].should == my_user
        assigns(:locations).should == [location]
        fake_location_list_presenter.received_message.should == :sort
      end
    end
  end

  describe 'GET ajax_vehicle_make' do
    context 'when vehicle user' do
      let (:current_user) { stub_vehicle_user(customer) }
      before do
        sign_in current_user
      end

      it 'should call vehicle_service to retrieve names' do
        fake_employee_service = controller.load_vehicle_service(Faker.new(['cat']))

        get :ajax_vehicle_make, {term: 'cat'}

        json = JSON.parse(response.body)
        json.should == ['cat']
        fake_employee_service.received_message.should == :get_vehicle_makes
        fake_employee_service.received_params[0].should == current_user
        fake_employee_service.received_params[1].should == 'cat'
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'should redirect, I suppose' do
        get :ajax_vehicle_make, {term: 'cat'}
        response.body.should eq("<html><body>You are being <a href=\"http://test.host/\">redirected</a>.</body></html>")
      end
    end

    context 'when admin user' do
      let (:current_user) { stub_admin(customer) }
      before do
        sign_in current_user
      end

      it 'should call vehicle_service to retrieve names' do
        fake_employee_service = controller.load_vehicle_service(Faker.new(['cat']))

        get :ajax_vehicle_make, {term: 'cat'}

        json = JSON.parse(response.body)
        json.should == ['cat']
        fake_employee_service.received_message.should == :get_vehicle_makes
        fake_employee_service.received_params[0].should == current_user
        fake_employee_service.received_params[1].should == 'cat'
      end
    end
  end

  describe 'GET ajax_vehicle_model' do
    context 'when vehicle user' do
      let (:current_user) { stub_vehicle_user(customer) }
      before do
        sign_in current_user
      end

      it 'should call vehicle_service to retrieve names' do
        fake_employee_service = controller.load_vehicle_service(Faker.new(['cat']))

        get :ajax_vehicle_model, {term: 'cat'}

        json = JSON.parse(response.body)
        json.should == ['cat']
        fake_employee_service.received_message.should == :get_vehicle_models
        fake_employee_service.received_params[0].should == current_user
        fake_employee_service.received_params[1].should == 'cat'
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'should redirect, I suppose' do
        get :ajax_vehicle_model, {term: 'cat'}
        response.body.should eq("<html><body>You are being <a href=\"http://test.host/\">redirected</a>.</body></html>")
      end
    end

    context 'when admin user' do
      let (:current_user) { stub_admin(customer) }
      before do
        sign_in current_user
      end

      it 'should call vehicle_service to retrieve names' do
        fake_employee_service = controller.load_vehicle_service(Faker.new(['cat']))

        get :ajax_vehicle_model, {term: 'cat'}

        json = JSON.parse(response.body)
        json.should == ['cat']
        fake_employee_service.received_message.should == :get_vehicle_models
        fake_employee_service.received_params[0].should == current_user
        fake_employee_service.received_params[1].should == 'cat'
      end
    end
  end
end

