require 'spec_helper'

describe LocationService do
  before do
    @my_customer = create_customer
    @my_location = create_location(customer: @my_customer)
    @other_location = create_location(customer: create_customer)
  end

  context 'when admin user' do
    it 'should return all locations' do
      admin_user = create_user(roles: ['admin'])

      LocationService.new.get_all_locations(admin_user).should == [@my_location, @other_location]
    end
  end

  context 'when regular user' do
    it "should return only customer's locations" do
      user = create_user(customer: @my_customer)

      LocationService.new.get_all_locations(user).should == [@my_location]
    end
  end
end