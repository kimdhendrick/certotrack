require 'spec_helper'

describe PaymentService do
  let(:subscription) { double(:subscription)}
  let(:subscriptions) { double(:subscriptions, create: subscription)}
  let(:stripe_customer) { double(:stripe_customer, id: 'stripe_cus_123', subscriptions: subscriptions) }
  let(:params) do
    {
        payment_token: 'token_123',
        payment_email: 'stripeEmail@example.com',
        subscription: 'annual',
    }
  end

  it 'should create stripe customer' do
    Stripe::Customer.should_receive(:create).
        with({
                 email: 'stripeEmail@example.com',
                 source: 'token_123'
             }).
        and_return(stripe_customer)

    described_class.new.process_payment(params)
  end

  it 'should create stripe subscription' do
    Stripe::Customer.stub(:create).and_return(stripe_customer)

    stripe_customer.should_receive(:subscriptions).and_return(subscriptions)
    subscriptions.should_receive(:create).
        with({plan: 'annual'}).
        and_return(subscription)

    described_class.new.process_payment(params)
  end

  it 'should return true on success' do
    Stripe::Customer.stub(:create).and_return(stripe_customer)

    status, _ = described_class.new.process_payment(params)
    status.should == true
  end

  it 'should return customer id on success' do
    stripe_customer.stub(:id).and_return('stripe_cus_123')
    Stripe::Customer.stub(:create).and_return(stripe_customer)

    _, customer_id = described_class.new.process_payment(params)
    customer_id.should == 'stripe_cus_123'
  end

  it 'should return false if customer is not returned' do
    Stripe::Customer.stub(:create).and_return(nil)

    status, _ = described_class.new.process_payment(params)
    status.should == false
  end

  it 'should return false if subscription is not returned' do
    Stripe::Customer.stub(:create).and_return(stripe_customer)
    subscriptions.stub(:create).and_return(nil)
    stripe_customer.stub(:subscriptions).and_return(subscriptions)

    status, _ = described_class.new.process_payment(params)
    status.should == false
  end

  it 'should return false on exception' do
    Stripe::Customer.stub(:create).and_return(stripe_customer)
    subscriptions.stub(:create).and_raise(Stripe::CardError.new('failure', nil, nil))
    stripe_customer.stub(:subscriptions).and_return(subscriptions)

    status, _ = described_class.new.process_payment(params)
    status.should == false
  end
end