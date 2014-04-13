require 'spec_helper'

describe CustomersController do
  describe 'GET #new' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns @customer' do

        get :new, {}, {}

        assigns(:customer).should be_a_new(Customer)
      end
    end

    context 'when not an admin user' do
      before do
        sign_in stub_equipment_user
      end

      it 'assigns does not assign @customer' do
        get :new, {}, {}

        assigns(:customer).should be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      let(:customer_attributes) do
        {
          name: 'Government',
          account_number: 'ABC123',
          equipment_access: 'true',
          certification_access: 'true',
          vehicle_access: 'true',
          contact_person_name: 'Joe Blow',
          contact_phone_number: '(303) 222-3333',
          contact_email: 'joe@example.com',
          address1: '123 Main St',
          address2: 'Suite 100',
          city: 'Denver',
          state: 'CO',
          zip: '80222'
        }
      end

      describe 'with valid params' do
        it 'creates a new customer' do
          fake_customer_service = Faker.new(build(:customer))
          controller.load_customer_service(fake_customer_service)

          post :create, {:customer => customer_attributes}, {}

          fake_customer_service.received_message.should == :create_customer
        end

        it 'assigns a newly created customer as @customer' do
          controller.load_customer_service(Faker.new(build(:customer)))

          post :create, {:customer => customer_attributes}, {}

          assigns(:customer).should be_a(Customer)
        end

        it 'redirects to the created customer' do
          customer = create(:customer, name: 'Government')
          controller.load_customer_service(Faker.new(customer))

          post :create, {:customer => customer_attributes}, {}

          response.should redirect_to(customer)
          flash[:notice].should == "Customer 'Government' was successfully created."
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved customer as @customer' do
          fake_customer_service = Faker.new(build(:customer))
          controller.load_customer_service(fake_customer_service)

          post :create, {:customer => {'name' => 'invalid value'}}, {}

          assigns(:customer).should be_a_new(Customer)
          fake_customer_service.received_message.should == :create_customer
        end

        it "re-renders the 'new' template" do
          controller.load_customer_service(Faker.new(build(:customer)))

          post :create, {:customer => {'name' => 'invalid value'}}, {}

          response.should render_template('new')
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns @customer' do
        customer = create(:customer)

        get :show, {:id => customer.to_param}, {}

        assigns(:customer).should eq(customer)
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign @customer' do
        customer = create(:customer)

        get :show, {:id => customer.to_param}, {}

        assigns(:customer).should be_nil
      end
    end
  end

  describe 'GET #index' do
    context 'when admin user' do
      let(:customer) { build(:customer) }
      let(:fake_customer_service_that_returns_list) { Faker.new([customer]) }
      let(:big_list_of_customers) do
        big_list_of_customers = []
        30.times do
          big_list_of_customers << create(:customer)
        end
        big_list_of_customers
      end
      let(:admin_user) { stub_admin }

      before do
        sign_in admin_user
      end

      context 'HTML format' do
        it 'calls get_all_customers with current_user and params' do
          fake_customers_service = controller.load_customer_service(Faker.new([]))
          fake_customers_list_presenter = Faker.new([])
          CustomerListPresenter.stub(:new).and_return(fake_customers_list_presenter)
          params = {sort: 'name', direction: 'asc'}

          get :index, params

          fake_customers_service.received_messages.should == [:get_all_customers]
          fake_customers_service.received_params[0].should == admin_user

          fake_customers_list_presenter.received_message.should == :present
          fake_customers_list_presenter.received_params[0]['sort'].should == 'name'
          fake_customers_list_presenter.received_params[0]['direction'].should == 'asc'
        end

        it 'assigns customers' do
          controller.load_customer_service(Faker.new([customer]))

          get :index, {}

          assigns(:customers).map(&:model).should eq([customer])
        end

        it 'assigns customer_count' do
          controller.load_customer_service(Faker.new(big_list_of_customers))

          get :index, {per_page: 25, page: 1}

          assigns(:customer_count).should eq(30)
        end

        it 'assigns report_title' do
          controller.load_customer_service(Faker.new([customer]))

          get :index

          assigns(:report_title).should eq('All Customers')
        end
      end

      context 'export' do
        subject { controller }
        it_behaves_like 'a controller that exports to csv, xls, and pdf',
                        resource: :customer,
                        load_method: :load_customer_service,
                        get_method: :get_all_customers,
                        action: :index,
                        report_title: 'All Customers',
                        filename: 'customers'
      end
    end

    context 'when guest user' do
      before do
        sign_in stub_guest_user
      end

      describe 'GET index' do
        it 'does not assign customers as @customers' do
          get :index

          assigns(:customers).should be_nil
        end
      end
    end
  end

  describe 'GET #edit' do
    context 'when an admin user' do
      before do
        sign_in stub_admin
      end

      it 'assigns the requested customer' do
        customer = create(:customer)

        get :edit, {:id => customer.to_param}, {}

        assigns(:customer).should eq(customer)
      end

      it 'assigns @states' do
        customer = create(:customer)

        get :edit, {:id => customer.to_param}, {}

        assigns(:states).should_not be_nil
      end
    end

    context 'when not an admin user' do
      it 'does not assign customer' do
        customer = create(:customer)

        get :edit, {:id => customer.to_param}, {}

        assigns(:customer).should be_nil
      end

      it 'does not assign states' do
        customer = create(:customer)

        get :edit, {:id => customer.to_param}, {}

        assigns(:states).should be_nil
      end
    end
  end

  describe 'PUT #update' do
    context 'when an admin user' do
      before do
        sign_in stub_admin
      end

      describe 'with valid params' do
        let(:customer_attributes) do
          {
            name: 'Government',
            account_number: 'ABC123',
            equipment_access: 'true',
            certification_access: 'true',
            vehicle_access: 'true',
            contact_person_name: 'Joe Blow',
            contact_phone_number: '(303) 222-3333',
            contact_email: 'joe@example.com',
            address1: '123 Main St',
            address2: 'Suite 100',
            city: 'Denver',
            state: 'CO',
            zip: '80222'
          }
        end

        it 'updates the requested customer' do
          customer = create(:customer)
          fake_customer_service = Faker.new(true)
          controller.load_customer_service(fake_customer_service)

          put :update, {:id => customer.to_param, :customer => customer_attributes}, {}

          fake_customer_service.received_message.should == :update_customer
          fake_customer_service.received_params[0].should == customer
        end

        it 'assigns the requested customer' do
          controller.load_customer_service(Faker.new(true))
          customer = create(:customer)

          put :update, {:id => customer.to_param, :customer => customer_attributes}, {}

          assigns(:customer).should eq(customer)
        end

        it 'redirects to the customer' do
          controller.load_customer_service(Faker.new(true))
          customer = create(:customer, name: 'Mine')

          put :update, {:id => customer.to_param, :customer => customer_attributes}, {}

          response.should redirect_to(customer)
          flash[:notice].should == "Customer 'Mine' was successfully updated."
        end
      end

      describe 'with invalid params' do
        it 'assigns the customer' do
          controller.load_customer_service(Faker.new(false))
          customer = create(:customer)

          put :update, {:id => customer.to_param, :customer => {'name' => 'invalid value'}}, {}

          assigns(:customer).should eq(customer)
        end

        it "re-renders the 'edit' template" do
          customer = create(:customer)
          controller.load_customer_service(Faker.new(false))

          put :update, {:id => customer.to_param, :customer => {'name' => 'invalid value'}}, {}

          response.should render_template('edit')
        end

        it 'assigns @states' do
          customer = create(:customer)
          controller.load_customer_service(Faker.new(false))

          put :update, {:id => customer.to_param, :customer => {'name' => 'invalid value'}}, {}

          assigns(:states).should_not be_nil
        end
      end
    end

    context 'when not an admin user' do
      before do
        sign_in stub_guest_user
      end

      it 'does not assign customer or states' do
        customer = create(:customer)
        controller.load_customer_service(Faker.new(false))

        put :update, {:id => customer.to_param, :customer => customer.to_param}, {}

        assigns(:customer).should be_nil
        assigns(:states).should be_nil
      end
    end
  end
end