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
end

