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

  describe '#create_vehicle' do
    context 'as a normal user' do
      it 'should create vehicle' do
        customer = build(:customer)
        golden = create(:location, name: 'Golden')
        current_user = create(:user, customer: customer)
        other_customer = build(:customer)
        attributes =
          {
              vehicle_number: '123',
              vin: '98765432109876543',
              license_plate: 'CTIsCool',
              year: '2013',
              make: 'Audi',
              vehicle_model: 'A3',
              mileage: '15',
              location_id: golden.id
            }

        vehicle = VehicleService.new.create_vehicle(current_user, attributes)

        vehicle.should be_persisted
        vehicle.vehicle_number.should == '123'
        vehicle.vin.should == '98765432109876543'
        vehicle.year.should == 2013
        vehicle.make.should == 'Audi'
        vehicle.vehicle_model.should == 'A3'
        vehicle.mileage.should == 15
        vehicle.location.should == golden
        vehicle.customer.should == customer
      end
    end
  end
end