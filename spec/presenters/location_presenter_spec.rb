require 'spec_helper'

describe LocationPresenter do

  let(:customer) { create(:customer, name: 'myCustomer') }
  let(:location) { build(:location, name: 'Denver', customer: customer) }

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

  it 'should respond to customer' do
    LocationPresenter.new(location).customer.should == customer
  end

  it 'should respond to sort_key' do
    LocationPresenter.new(location).sort_key.should == 'Denver'
  end

  describe 'edit_link' do
    it 'should create a link to the edit page' do
      location = create(:location)
      subject = LocationPresenter.new(location, view)
      subject.edit_link.should =~ /<a.*>Edit<\/a>/
    end
  end

  describe 'delete_link' do
    it 'should create a link to the delete page' do
      location = build(:location)
      subject = LocationPresenter.new(location, view)
      subject.delete_link.should =~ /<a.*>Delete<\/a>/
    end
  end
end