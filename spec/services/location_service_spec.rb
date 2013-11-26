require 'spec_helper'

describe LocationService do
  let(:my_customer) { create(:customer) }
  let!(:my_location) { create(:location, customer: my_customer) }
  let!(:other_location) { create(:location) }

  describe '#get_all_locations' do
    context 'when admin user' do
      it 'should return all locations' do
        admin_user = create(:user, roles: ['admin'])

        locations = LocationService.new.get_all_locations(admin_user)

        locations.should =~ [my_location, other_location]
      end
    end

    context 'when regular user' do
      it "should return only customer's locations" do
        user = create(:user, customer: my_customer)

        locations = LocationService.new.get_all_locations(user)

        locations.should == [my_location]
      end
    end
  end

  describe '#create_location' do
    context 'as a normal user' do
      it 'should create location' do
        customer = build(:customer)
        current_user = create(:user, customer: customer)
        other_customer = build(:customer)
        attributes =
          {
            'name' => 'Alaska',
            'customer_id' => other_customer.id
          }

        location = LocationService.new.create_location(current_user, attributes)

        location.should be_persisted
        location.name.should == 'Alaska'
        location.customer.should == customer
      end
    end
    context 'as an admin user' do
      it 'should create location' do
        other_customer = create(:customer)
        admin_user = create(:user, roles: ['admin'])
        attributes =
          {
            'name' => 'Alaska',
            'customer_id' => other_customer.id
          }

        location = LocationService.new.create_location(admin_user, attributes)

        location.should be_persisted
        location.name.should == 'Alaska'
        location.customer.should == other_customer
      end
    end
  end
end