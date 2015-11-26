require 'spec_helper'

describe RegistrationService do
  describe '#register' do

    let(:registration_params) do
      {
          'first_name' => 'Sally',
          'last_name' => 'Smith',
          'customer_name' => 'New Customer',
          'password' => 'Password123!',
          'password_confirm' => 'Password123!',
          'subscription' => 'monthly',
          'payment_token' => 'tok_123',
          'payment_email' => 'sally@gmail.com',
      }
    end
    let(:customer_service) { double(:customer_service) }
    let(:user_service) { double(:user_service) }
    let(:payment_service) { double(:payment_service) }
    let(:customer) { create(:customer) }
    let(:invalid_user) { User.new }
    let(:invalid_customer) { Customer.new }
    let(:sut) { described_class.new(customer_service: customer_service, user_service: user_service, payment_service: payment_service) }

    before do
      customer_service.stub(:create_customer).and_return(customer)
      user_service.stub(:create_user).and_return(create(:user))
      payment_service.stub(:process_payment).and_return(true)

      invalid_user.should_not be_valid
      invalid_customer.should_not be_valid
    end

    it 'should return true on success' do
      status, registration = sut.register(registration_params)

      status.should be_true
      registration.should be_valid
    end

    describe 'registration validation' do
      it 'should return false on registration errors' do
        registration_params.merge!({'customer_name' => ''})

        status, registration = sut.register(registration_params)

        status.should be_false
        registration.errors[:customer_name].should == ["can't be blank"]
      end
    end

    describe 'customer creation' do
      it 'should create a customer' do
        customer_service.should_receive(:create_customer).with(
            {
                name: 'New Customer',
                contact_person_name: 'Sally Smith',
                account_number: 'sally@gmail.com',
                contact_email: 'sally@gmail.com',
                subscription: 'monthly',
                equipment_access: true,
                certification_access: true,
            }
        ).and_return(customer)

        status, _ = sut.register(registration_params)

        status.should be_true
      end

      it 'should return false on customer errors' do
        customer_service.stub(:create_customer).and_return(invalid_customer)

        status, _ = sut.register(registration_params)

        status.should be_false
      end

      it 'should populate registration with customer errors' do
        customer_service.stub(:create_customer).and_return(invalid_customer)

        _, registration = sut.register(registration_params)

        registration.errors[:name].should == ["can't be blank"]
      end
    end

    describe 'user creation' do
      it 'should create a user' do
        customer_service.stub(:create_customer).and_return(customer)

        user_service.should_receive(:create_user).with(
            {
                first_name: 'Sally',
                last_name: 'Smith',
                password: 'Password123!',
                customer: customer,
                email: 'sally@gmail.com',
                username: 'sally@gmail.com',
                expiration_notification_interval: 'Weekly',
            }
        )

        status, _ = sut.register(registration_params)

        status.should be_true
      end

      it 'should return false on user errors' do
        user_service.stub(:create_user).and_return(invalid_user)

        status, _ = sut.register(registration_params)

        status.should be_false
      end

      it 'should populate registration with user errors' do
        user_service.stub(:create_user).and_return(invalid_user)

        _, registration = sut.register(registration_params)

        registration.errors[:password].should == [
            "can't be blank",
            'is too short (minimum is 1 characters)',
            'must be at least 8 characters long and must contain at least one digit and combination of upper and lower case.',
        ]
        registration.errors[:first_name].should == ["can't be blank"]
      end
    end

    describe 'payment processing' do
      it 'should process payment' do
        payment_service.should_receive(:process_payment).
            with(
                {
                    payment_token: 'tok_123',
                    payment_email: 'sally@gmail.com',
                    subscription: 'monthly',
                }
            ).and_return([true, ''])

        status, _ = sut.register(registration_params)

        status.should be_true
      end

      it 'should return false on payment errors' do
        payment_service.stub(:process_payment).and_return([false, nil])

        status, _ = sut.register(registration_params)

        status.should be_false
      end

      it 'should update the customer payment_processor_customer_id upon payment processed' do
        payment_service.stub(:process_payment).and_return([true, 'cus_7Oo4c0GV4B2sF4'])

        sut.register(registration_params)

        customer.reload
        customer.payment_processor_customer_id.should == 'cus_7Oo4c0GV4B2sF4'
      end
    end

    describe 'transactional behavior' do
      it 'should rollback customer creation if user creation fails' do
        user_service.stub(:create_user).and_return(invalid_user)

        sut = described_class.new(user_service: user_service, payment_service: payment_service)

        expect { sut.register(registration_params) }.not_to change(Customer, :count)
      end

      it 'should rollback customer creation if payment fails' do
        payment_service.stub(:process_payment).and_return([false, nil])

        sut = described_class.new(payment_service: payment_service)

        expect { sut.register(registration_params) }.not_to change(Customer, :count)
      end

      it 'should rollback user creation if payment fails' do
        payment_service.stub(:process_payment).and_return([false, nil])

        sut = described_class.new(payment_service: payment_service)

        expect { sut.register(registration_params) }.not_to change(User, :count)
      end

      it 'should not process payment if registration has errors' do
        payment_service.stub(:process_payment).and_raise('Should not call payment service')

        sut = described_class.new(payment_service: payment_service)

        _, registration = sut.register({})

        registration.should_not be_valid
      end

      it 'should not process payment if customer creation fails' do
        customer_service.stub(:create_customer).and_return(invalid_customer)
        payment_service.stub(:process_payment).and_raise('Should not call payment service')

        described_class.new(customer_service: customer_service, payment_service: payment_service).register(registration_params)
      end

      it 'should not process payment if user creation fails' do
        user_service.stub(:create_user).and_return(invalid_user)
        payment_service.stub(:process_payment).and_raise('Should not call payment service')

        described_class.new(user_service: user_service, payment_service: payment_service).register(registration_params)
      end
    end
  end
end