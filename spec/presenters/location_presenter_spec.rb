require 'spec_helper'

describe LocationPresenter do

  let(:location) { build(:location, name: 'Denver', customer: create(:customer, name: 'myCustomer')) }

  it 'should respond to model' do
    LocationPresenter.new(location).model.should == location
  end

  it 'should respond to id' do
    LocationPresenter.new(location).id.should == location.id
  end

  it 'should respond to name' do
    LocationPresenter.new(location).name.should == 'Denver'
  end

  it 'should respond to customer name' do
    LocationPresenter.new(location).customer_name.should == 'myCustomer'
  end

  it 'should respond to sort_key' do
    LocationPresenter.new(location).sort_key.should == 'Denver'
  end
end