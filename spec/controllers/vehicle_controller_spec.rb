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
end

