require 'spec_helper'

describe VehiclesController do
  let(:customer) { build(:customer) }
  let(:vehicle) { build(:vehicle) }

  describe 'GET index' do
    context 'when vehicle user' do
      before do
        @my_user = stub_vehicle_user(customer)
        sign_in @my_user
        controller.load_vehicle_service(Faker.new([vehicle]))
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

      it 'assigns vehicles as @vehicles' do
        get :index

        assigns(:vehicles).map(&:model).should eq([vehicle])
      end

      it 'assigns vehicle_count' do
        get :index

        assigns(:vehicle_count).should eq(1)
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

      it 'assigns vehicles as @vehicles' do
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

      it 'assigns a new vehicle as @vehicle' do

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

      it 'assigns a new vehicle as @vehicle' do
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

      it 'does not assign vehicle as @vehicle' do
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

        it 'assigns a newly created vehicle as @vehicle' do
          controller.load_vehicle_service(Faker.new(build(:vehicle)))

          post :create, {:vehicle => {vin: '98765432109876543'}}, {}

          assigns(:vehicle).should be_a(Vehicle)
        end

        it 'redirects to the created vehicle' do
          vehicle = create(:vehicle)
          controller.load_vehicle_service(Faker.new(vehicle))

          post :create, {:vehicle => {vin: '98765432109876543'}}, {}

          response.should redirect_to(Vehicle.last)
          flash[:notice].should == 'Vehicle was successfully created.'
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved vehicle as @vehicle' do
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

      it 'assigns a newly created vehicle as @vehicle' do
        controller.load_vehicle_service(Faker.new(build(:vehicle)))

        post :create, {:vehicle => {vin: '123'}}, {}

        assigns(:vehicle).should be_a(Vehicle)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign vehicle as @vehicle' do
        expect {
          post :create, {:vehicle => {vin: '123'}}, {}
        }.not_to change(Vehicle, :count)
        assigns(:vehicle).should be_nil
      end
    end
  end

  describe 'GET show' do
    context 'when vehicle user' do
      before do
        sign_in stub_vehicle_user(customer)
      end

      it 'assigns vehicle as @vehicle' do
        vehicle = create(:vehicle, customer: customer)

        get :show, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should eq(vehicle)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns vehicle as @vehicle' do

        vehicle = create(:vehicle, customer: customer)

        get :show, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should eq(vehicle)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign vehicle as @vehicle' do
        vehicle = create(:vehicle, customer: customer)

        get :show, {:id => vehicle.to_param}, {}

        assigns(:vehicle).should be_nil
      end
    end
  end
end

