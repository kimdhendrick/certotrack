require 'spec_helper'

describe LocationService do
  let(:my_customer) { create(:customer) }
  let!(:my_location) { create(:location, customer: my_customer) }
  let!(:other_location) { create(:location) }

  context 'when admin user' do
    it 'should return all locations' do
      admin_user = create(:user, roles: ['admin'])
      Sorter.any_instance.should_receive(:sort).and_call_original

      LocationService.new.get_all_locations(admin_user).should == [my_location, other_location]
    end
  end

  context 'when regular user' do
    it "should return only customer's locations" do
      user = create(:user, customer: my_customer)
      Sorter.any_instance.should_receive(:sort).and_call_original

      LocationService.new.get_all_locations(user).should == [my_location]
    end
  end
end