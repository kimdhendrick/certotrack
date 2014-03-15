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

  describe 'GET #new' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns a new user' do
        get :new, {customer_id: 1}, {}

        assigns(:user).should be_a_new(User)
      end

      it 'assigns a new user to the correct customer' do
        customer = create(:customer)

        get :new, {customer_id: customer.id}, {}

        assigns(:user).customer.should == customer
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign user' do
        get :new, {}, {}

        assigns(:user).should be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      describe 'with valid params' do
        it 'creates a new user' do
          fake_user_service = Faker.new(build(:user))
          controller.load_user_service(fake_user_service)

          post :create, {:user => {first_name: 'Heather', last_name: 'Jones'}}, {}

          fake_user_service.received_message.should == :create_user
        end

        it 'assigns a newly created user' do
          controller.load_user_service(Faker.new(build(:user)))

          post :create, {:user => {first_name: 'Heather', last_name: 'Jones'}}, {}

          assigns(:user).should be_a(User)
        end

        it 'redirects to the created user' do
          user = create(:user)
          controller.load_user_service(Faker.new(user))

          post :create, {:user => {first_name: 'Heather', last_name: 'Jones'}}, {}

          response.should redirect_to(customer_user_path(User.last))
          flash[:notice].should == 'User was successfully created.'
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved user' do
          fake_user_service = Faker.new(build(:user))
          controller.load_user_service(fake_user_service)

          post :create, {:user => {first_name: 'invalid value'}}, {}

          assigns(:user).should be_a_new(User)
          fake_user_service.received_message.should == :create_user
        end

        it "re-renders the 'new' template" do
          controller.load_user_service(Faker.new(build(:user)))

          post :create, {:user => {first_name: 'invalid value'}}, {}

          response.should render_template('new')
        end
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign user' do
        expect {
          post :create, {:user => {first_name: 'Heather'}}, {}
        }.not_to change(User, :count)
        assigns(:user).should be_nil
      end
    end
  end

  describe 'GET #edit' do
    context 'when an admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns the user' do
        user = create(:user)

        get :edit, {:id => user.to_param}, {}

        assigns(:user).should eq(user)
      end

      it 'assigns a sorted list of customers to @customers' do
        user = create(:user)
        customer = create(:customer)
        fake_customer_service = Faker.new([customer])
        controller.load_customer_service(fake_customer_service)
        fake_customer_list_presenter = Faker.new([customer])
        CustomerListPresenter.stub(:new).and_return(fake_customer_list_presenter)

        get :edit, {:id => user.to_param}, {}

        assigns(:customers).should == [customer]
        fake_customer_list_presenter.received_message.should == :sort
      end
    end

    context 'when not an admin user' do
      it 'does not assign user' do
        user = create(:user)

        get :edit, {:id => user.to_param}, {}

        assigns(:user).should be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'when an admin user' do
      before do
        sign_in stub_admin
      end

      describe 'with valid params' do
        let(:user_attributes) do
          {
            first_name: 'Gary',
            last_name: 'Snail'
          }
        end

        it 'updates the requested user' do
          user = create(:user)
          fake_user_service = Faker.new(true)
          controller.load_user_service(fake_user_service)

          put :update, {:id => user.to_param, :user => user_attributes}, {}

          fake_user_service.received_message.should == :update_user
          fake_user_service.received_params[1].should == user
        end

        it 'assigns the requested user' do
          controller.load_user_service(Faker.new(true))
          user = create(:user)

          put :update, {:id => user.to_param, :user => user_attributes}, {}

          assigns(:user).should eq(user)
        end

        it 'redirects to the user' do
          controller.load_user_service(Faker.new(true))
          user = create(:user)

          put :update, {:id => user.to_param, :user => user_attributes}, {}

          response.should redirect_to(customer_user_path(user))
          flash[:notice].should == 'User was successfully updated.'
        end
      end

      describe 'with invalid params' do
        it 'assigns the user' do
          controller.load_user_service(Faker.new(false))
          user = create(:user)

          put :update, {:id => user.to_param, :user => {first_name: 'invalid value'}}, {}

          assigns(:user).should eq(user)
        end

        it "re-renders the 'edit' template" do
          user = create(:user)
          controller.load_user_service(Faker.new(false))

          put :update, {:id => user.to_param, :user => {first_name: 'invalid value'}}, {}

          response.should render_template('edit')
        end
      end
    end

    context 'when not an admin user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign user' do
        user = create(:user)
        controller.load_user_service(Faker.new(false))

        put :update, {:id => user.to_param, :user => user.to_param}, {}

        assigns(:user).should be_nil
      end
    end
  end
  
  describe 'DELETE #destroy' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'calls user_service' do
        user = create(:user)
        fake_user_service = Faker.new(true)
        controller.load_user_service(fake_user_service)

        delete :destroy, {:id => user.to_param}, {}

        fake_user_service.received_message.should == :delete_user
        fake_user_service.received_params[0].should == user
      end

      context 'when destroy call fails' do
        before do
          user = create(:user)
          user_service = double('user_service')
          user_service.stub(:delete_user).and_return(false)
          controller.load_user_service(user_service)

          delete :destroy, {id: user.to_param}, {}
        end

        it 'should render show page' do
          response.should render_template('show')
        end
      end

      it 'redirects to the user list' do
        user = create(:user, first_name: 'Julie', last_name: 'Doe')
        controller.load_user_service(Faker.new(true))

        delete :destroy, {:id => user.to_param}, {}

        response.should redirect_to(customer_users_path)
        flash[:notice].should == "User 'Doe, Julie' was successfully deleted."
      end
    end
  end
end