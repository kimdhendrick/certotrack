require 'spec_helper'

describe LocationsController do
  let(:customer) { build(:customer) }
  let(:location) { build(:location) }

  describe 'GET index' do
    context 'when equipment user' do
      before do
        @my_user = stub_equipment_user(customer)
        sign_in @my_user
        controller.load_location_service(Faker.new([location]))
      end

      it 'calls get_all_locations with current_user and params' do
        fake_location_service = controller.load_location_service(Faker.new([]))

        get :index, {}

        fake_location_service.received_messages.should == [:get_all_locations]
        fake_location_service.received_params[0].should == @my_user
      end

      it 'presents locations with LocationListPresenter' do
        controller.load_location_service(Faker.new([]))
        fake_location_list_presenter = Faker.new([])
        LocationListPresenter.stub(:new).and_return(fake_location_list_presenter)
        params = {sort: 'name', direction: 'asc'}

        get :index, params

        fake_location_list_presenter.received_message.should == :present
        fake_location_list_presenter.received_params[0]['sort'].should == 'name'
        fake_location_list_presenter.received_params[0]['direction'].should == 'asc'
      end

      it 'assigns locations as @locations' do
        get :index

        assigns(:locations).map(&:model).should eq([location])
      end

      it 'assigns location_count' do
        get :index

        assigns(:location_count).should eq(1)
      end

      it 'assigns report_title' do
        get :index

        assigns(:report_title).should eq('All Locations')
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
        controller.load_location_service(Faker.new([location]))
      end

      it 'assigns locations as @locations' do
        get :index

        assigns(:locations).map(&:model).should eq([location])
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign locations' do
          get :index

          assigns(:locations).should be_nil
        end
      end
    end
  end

  describe 'GET new' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'assigns a new location as @location' do

        get :new, {}, {}

        assigns(:location).should be_a_new(Location)
      end

      it 'does not assign a list of customers to @customers' do
        get :new, {}, {}

        assigns(:customers).should == []
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns a new location as @location' do
        get :new, {}, {}

        assigns(:location).should be_a_new(Location)
      end

      it 'assigns a sorted list of customers to @customers' do
        customer = build(:customer)
        fake_customer_service = Faker.new([customer])
        controller.load_customer_service(fake_customer_service)
        fake_customer_list_presenter = Faker.new([customer])
        CustomerListPresenter.stub(:new).and_return(fake_customer_list_presenter)

        get :new, {}, {}

        assigns(:customers).should == [customer]
        fake_customer_list_presenter.received_message.should == :sort
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign location as @location' do
        get :new, {}, {}

        assigns(:location).should be_nil
      end
    end
  end

  describe 'POST create' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      describe 'with valid params' do
        it 'creates a new location' do
          fake_location_service = Faker.new(build(:location))
          controller.load_location_service(fake_location_service)

          post :create, {:location => {name: 'Hawaii'}}, {}

          fake_location_service.received_message.should == :create_location
        end

        it 'assigns a newly created location as @location' do
          controller.load_location_service(Faker.new(build(:location)))

          post :create, {:location => {name: 'Hawaii'}}, {}

          assigns(:location).should be_a(Location)
        end

        it 'redirects to the created location' do
          location = create(:location)
          controller.load_location_service(Faker.new(location))

          post :create, {:location => {name: 'Hawaii'}}, {}

          response.should redirect_to(Location.last)
          flash[:notice].should == 'Location was successfully created.'
        end
      end

      describe 'with invalid params' do
          it 'assigns a newly created but unsaved location as @location' do
            fake_location_service = Faker.new(build(:location))
            controller.load_location_service(fake_location_service)

            post :create, {:location => {'name' => 'invalid value'}}, {}

            assigns(:location).should be_a_new(Location)
            fake_location_service.received_message.should == :create_location
          end

          it "re-renders the 'new' template" do
            controller.load_location_service(Faker.new(build(:location)))

            post :create, {:location => {'name' => 'invalid value'}}, {}

            response.should render_template('new')
          end

          it 'does not assign @customers' do
            customer = build(:customer)
            fake_customer_service = Faker.new([customer])
            controller.load_customer_service(fake_customer_service)

            post :create, {:location => {'name' => 'invalid value'}}, {}

            assigns(:customers).should be_nil
          end
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls LocationService' do
        customer = create(:customer)
        fake_location_service = Faker.new(build(:location))
        controller.load_location_service(fake_location_service)

        post :create, {:location => {name: 'Hawaii', customer_id: customer.id}}, {}

        fake_location_service.received_message.should == :create_location
      end

      it 'assigns a newly created location as @location' do
        controller.load_location_service(Faker.new(build(:location)))

        post :create, {:location => {name: 'Hawaii', customer_id: customer.id}}, {}

        assigns(:location).should be_a(Location)
      end

      describe 'with invalid params' do
        it 'assigns a sorted list of customers to @customers' do
          customer = build(:customer)
          fake_customer_service = Faker.new([customer])
          controller.load_customer_service(fake_customer_service)
          fake_customer_list_presenter = Faker.new([customer])
          CustomerListPresenter.stub(:new).and_return(fake_customer_list_presenter)

          post :create, {:location => {'name' => 'invalid value'}}, {}

          assigns(:customers).should == [customer]
          fake_customer_list_presenter.received_message.should == :sort
        end
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign location as @location' do
        expect {
          post :create, {:location => {name: 'Hawaii', customer_id: customer.id}}, {}
        }.not_to change(Location, :count)
        assigns(:location).should be_nil
      end
    end
  end

  describe 'GET show' do
    context 'when equipment user' do
      before do
        sign_in stub_equipment_user(customer)
      end

      it 'assigns location as @location' do
        location = create(:location, customer: customer)

        get :show, {:id => location.to_param}, {}

        assigns(:location).should eq(location)
      end
    end

    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns location as @location' do

        location = create(:location, customer: customer)

        get :show, {:id => location.to_param}, {}

        assigns(:location).should eq(location)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign location as @location' do
        location = create(:location, customer: customer)

        get :show, {:id => location.to_param}, {}

        assigns(:location).should be_nil
      end
    end
  end
end

