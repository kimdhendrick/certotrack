require 'spec_helper'

describe RegistrationsController do
  describe 'GET new' do
    it 'assigns @registration' do
      get :new, {}, {}
      assigns(:registration).should be_an_instance_of(Registration)
    end

    it 'assigns @subscriptions' do
      get :new, {}, {}
      assigns(:subscriptions).should == Subscription.all
    end
  end

  describe 'POST create' do
    let(:params) do
      {
          'registration' => {
              'first_name' => 'Sally',
              'last_name' => 'Smith',
              'customer_name' => 'New Customer',
              'password' => 'password123',
              'subscription' => 'monthly',
          },
          'stripeToken' => 'tok_123',
          'stripeTokenType' => 'card',
          'stripeEmail' => 'sally@gmail.com',
      }
    end
    let(:registration_service) { double('registration_service') }

    before do
      controller.load_registration_service(registration_service)
    end

    it 'should call RegistrationService#register' do
      registration_service.should_receive('register').with(
          {
              'first_name' => 'Sally',
              'last_name' => 'Smith',
              'customer_name' => 'New Customer',
              'password' => 'password123',
              'subscription' => 'monthly',
              'payment_token' => 'tok_123',
              'payment_email' => 'sally@gmail.com',
          },
      ).and_return(true)

      get :create, params, {}

      response.status.should == 200
    end

    it 'should render confirmation page on success' do
      registration_service.stub(:register).and_return(true)

      get :create, params, {}

      response.should render_template('create')
    end

    it 'should render new on failure' do
      registration_service.stub(:register).and_return(false)

      get :create, params, {}

      response.should render_template('new')
    end
  end
end