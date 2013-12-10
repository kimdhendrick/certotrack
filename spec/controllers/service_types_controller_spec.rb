require 'spec_helper'

describe ServiceTypesController do
  let(:customer) { build(:customer) }
  let(:service_type) { build(:service_type) }

  describe 'GET index' do
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
end
