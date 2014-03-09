require 'spec_helper'

describe LocationService do
  let(:my_customer) { create(:customer) }
  let!(:my_location) { create(:location, customer: my_customer) }
  let!(:other_location) { create(:location) }

  describe '#get_all_locations' do
    context 'when admin user' do
      it 'should return all locations' do
        admin_user = create(:user, admin: true)

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
        admin_user = create(:user, admin: true)
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

  describe '#update_location' do
    context 'admin user' do
      it 'should update locations attributes' do
        admin_user = create(:user, admin: true)
        other_customer = create(:customer)
        location = create(:location, customer: my_customer)
        attributes =
          {
            'id' => location.id,
            'name' => 'Aruba',
            'customer_id' => other_customer.id
          }

        success = LocationService.new.update_location(admin_user, location, attributes)
        success.should be_true

        location.reload
        location.name.should == 'Aruba'
        location.customer.should == other_customer
      end
    end

    context 'a normal user' do
      let (:current_user) { create(:user, customer: my_customer)}

      it 'should update locations attributes except customer' do
        other_customer = create(:customer)
        location = create(:location, customer: my_customer)
        attributes =
          {
            'id' => location.id,
            'name' => 'Aruba',
            'customer_id' => other_customer.id
          }

        success = LocationService.new.update_location(current_user, location, attributes)
        success.should be_true

        location.reload
        location.name.should == 'Aruba'
        location.customer.should == my_customer
      end

      it 'should return false if errors' do
        location = create(:location, customer: my_customer)
        location.stub(:save).and_return(false)

        success = LocationService.new.update_location(current_user, location, {})
        success.should be_false

        location.reload
        location.name.should_not == 'Box'
      end
    end
  end

  describe '#delete_location' do
    it 'destroys the requested location' do
      location = create(:location, customer: my_customer)

      expect {
        LocationService.new.delete_location(location)
      }.to change(Location, :count).by(-1)
    end
  end
end