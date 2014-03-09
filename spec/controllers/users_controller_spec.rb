require 'spec_helper'

describe UsersController do
  describe 'GET #index' do
    context 'when admin user' do
      let(:user) { build(:user) }
      let(:fake_user_service_that_returns_list) { Faker.new([user]) }
      let(:big_list_of_users) do
        big_list_of_users = []
        30.times do
          big_list_of_users << create(:user)
        end
        big_list_of_users
      end
      let(:admin_user) { stub_admin }

      before do
        sign_in admin_user
      end

      it 'calls get_all_users with current_user and params' do
        fake_user_service = controller.load_user_service(Faker.new([]))
        fake_user_list_presenter = Faker.new([])
        UserListPresenter.stub(:new).and_return(fake_user_list_presenter)
        params = {sort: 'name', direction: 'asc'}

        get :index, params

        fake_user_service.received_messages.should == [:get_all_users]
        fake_user_service.received_params[0].should == admin_user

        fake_user_list_presenter.received_message.should == :present
        fake_user_list_presenter.received_params[0]['sort'].should == 'name'
        fake_user_list_presenter.received_params[0]['direction'].should == 'asc'
      end

      it 'assigns users' do
        controller.load_user_service(fake_user_service_that_returns_list)

        get :index, {}

        assigns(:users).map(&:model).should eq([user])
      end

      it 'assigns user_count' do
        controller.load_user_service(Faker.new(big_list_of_users))

        get :index, {per_page: 25, page: 1}

        assigns(:user_count).should eq(30)
      end

      it 'assigns report_title' do
        controller.load_user_service(fake_user_service_that_returns_list)

        get :index

        assigns(:report_title).should eq('All Users')
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign users' do
          get :index

          assigns(:users).should be_nil
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns user' do
        user = create(:user)

        get :show, {:id => user.to_param}, {}

        assigns(:user).should eq(user)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign @user' do
        user = create(:user)

        get :show, {:id => user.to_param}, {}

        assigns(:user).should be_nil
      end
    end
  end
end