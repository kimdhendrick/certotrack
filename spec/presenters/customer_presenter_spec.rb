require 'spec_helper'

describe CustomerPresenter do

  let(:customer) do
    build(
      :customer,
      name: 'Jefferson County',
      account_number: 'ABC123',
      contact_person_name: 'Joe Blow', 
      contact_phone_number: '(303) 222-1234',
      contact_email: 'joe@example.com', 
      address1: '123 Main St', 
      address2: 'Suite 100',
      city: 'Denver', 
      state: 'CO',
      zip: '80222',
      equipment_access: true,
      certification_access: true,
      vehicle_access: true
    )
  end

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

  it 'should respond to account_number' do
    CustomerPresenter.new(customer).account_number.should == 'ABC123'
  end

  it 'should respond to contact_person_name' do
    CustomerPresenter.new(customer).contact_person_name.should == 'Joe Blow'
  end

  it 'should respond to contact_phone_number' do
    CustomerPresenter.new(customer).contact_phone_number.should == '(303) 222-1234'
  end

  it 'should respond to contact_email' do
    CustomerPresenter.new(customer).contact_email.should == 'joe@example.com'
  end

  it 'should respond to address1' do
    CustomerPresenter.new(customer).address1.should == '123 Main St'
  end

  it 'should respond to address2' do
    CustomerPresenter.new(customer).address2.should == 'Suite 100'
  end

  it 'should respond to city' do
    CustomerPresenter.new(customer).city.should == 'Denver'
  end

  it 'should respond to state' do
    CustomerPresenter.new(customer).state.should == 'CO'
  end

  it 'should respond to zip' do
    CustomerPresenter.new(customer).zip.should == '80222'
  end

  it 'should respond to equipment_access' do
    CustomerPresenter.new(customer).equipment_access.should == 'Yes'
  end

  it 'should respond to certification_access' do
    CustomerPresenter.new(customer).certification_access.should == 'Yes'
  end

  it 'should respond to vehicle_access' do
    CustomerPresenter.new(customer).vehicle_access.should == 'Yes'
  end

  it 'should respond to created_at' do
    customer = CustomerPresenter.new(create(:customer, created_at: Date.new(2010, 1, 1)))
    customer.created_at.should == '01/01/2010'
  end

  it 'should respond to active' do
    customer = CustomerPresenter.new(create(:customer))
    customer.active.should == 'Yes'
  end

  it 'should return sorted locations' do
    customer.locations << build(:location, name: 'Denver', customer: customer)
    customer.locations << build(:location, name: 'Boulder', customer: customer)
    customer.locations << build(:location, name: 'Golden', customer: customer)

    locations = CustomerPresenter.new(customer).locations

    locations.first.should be_a(LocationPresenter)
    locations.map(&:name).should == ['Boulder', 'Denver', 'Golden']
  end

  it 'should return sorted users' do
    customer.users << build(:user, username: 'ZZZ', customer: customer)
    customer.users << build(:user, username: 'AAA', customer: customer)
    customer.users << build(:user, username: 'GGG', customer: customer)

    users = CustomerPresenter.new(customer).users

    users.first.should be_a(UserPresenter)
    users.map(&:username).should == ['AAA', 'GGG', 'ZZZ']
  end

  describe 'edit_link' do
    it 'should create a link to the edit page' do
      customer = build(:customer)
      subject = CustomerPresenter.new(customer, view)
      subject.edit_link.should =~ /<a.*>Edit<\/a>/
    end
  end
end