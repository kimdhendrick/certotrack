require 'spec_helper'

describe LocationService do
  let(:my_customer) { create(:customer) }
  let!(:my_location) { create(:location, customer: my_customer) }
  let!(:other_location) { create(:location) }

  context 'when admin user' do
    it 'should sort all locations' do
      admin_user = create(:user, roles: ['admin'])
      fake_sorter = Faker.new

      LocationService.new(sorter: fake_sorter).get_all_locations(admin_user)

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0].should =~ [my_location, other_location]
    end
  end

  context 'when regular user' do
    it "should sort only customer's locations" do
      user = create(:user, customer: my_customer)
      fake_sorter = Faker.new

      LocationService.new(sorter: fake_sorter).get_all_locations(user)

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0].should == [my_location]
    end
  end
end