require 'spec_helper'

describe VehicleService do
  let(:my_customer) { create(:customer) }
  let!(:my_vehicle) { create(:vehicle, customer: my_customer) }
  let!(:other_vehicle) { create(:vehicle) }

  describe '#get_all_vehicles' do
    context 'when admin user' do
      it 'should return all vehicles' do
        admin_user = create(:user, roles: ['admin'])

        vehicles = VehicleService.new.get_all_vehicles(admin_user)

        vehicles.should =~ [my_vehicle, other_vehicle]
      end
    end

    context 'when regular user' do
      it "should return only customer's vehicles" do
        user = create(:user, customer: my_customer)

        vehicles = VehicleService.new.get_all_vehicles(user)

        vehicles.should == [my_vehicle]
      end
    end
  end
end