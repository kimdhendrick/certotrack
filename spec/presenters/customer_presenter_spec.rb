require 'spec_helper'

describe CustomerPresenter do

  let(:customer) { build(:customer, name: 'Jefferson County') }

  it 'should respond to model' do
    CustomerPresenter.new(customer).model.should == customer
  end

  it 'should respond to id' do
    CustomerPresenter.new(customer).id.should == customer.id
  end

  it 'should respond to name' do
    CustomerPresenter.new(customer).name.should == 'Jefferson County'
  end

  it 'should respond to sort_key' do
    CustomerPresenter.new(customer).sort_key.should == 'Jefferson County'
  end
end