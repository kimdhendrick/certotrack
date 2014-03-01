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

  describe 'GET show' do
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
end