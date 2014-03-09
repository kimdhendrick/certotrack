require 'spec_helper'

describe UserPresenter do

  let(:customer) do
    build(
      :customer,
      name: 'My Customer',
      equipment_access: true,
      certification_access: true,
      vehicle_access: true
    )
  end

  let(:user) do
    build(
      :user,
      username: 'user1',
      first_name: 'Bob',
      last_name: 'Smith',
      customer: customer,
      roles: customer.roles
    )
  end

  it 'should respond to model' do
    UserPresenter.new(user).model.should == user
  end

  it 'should respond to id' do
    UserPresenter.new(user).id.should == user.id
  end

  it 'should respond to username' do
    UserPresenter.new(user).username.should == 'user1'
  end

  it 'should respond to first name' do
    UserPresenter.new(user).first_name.should == 'Bob'
  end

  it 'should respond to first name' do
    UserPresenter.new(user).last_name.should == 'Smith'
  end

  it 'should respond to sort_key' do
    UserPresenter.new(user).sort_key.should == 'user1'
  end

  it 'should respond to equipment_access' do
    UserPresenter.new(user).equipment_access.should == 'Yes'
  end

  it 'should respond to certification_access' do
    UserPresenter.new(user).certification_access.should == 'Yes'
  end

  it 'should respond to vehicle_access' do
    UserPresenter.new(user).vehicle_access.should == 'Yes'
  end

  it 'should respond to customer_name' do
    UserPresenter.new(user).customer_name.should == 'My Customer'
  end

  it 'should respond to customer' do
    UserPresenter.new(user).customer.should == customer
  end
end