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

  describe '#update_vehicle' do
    context 'a normal user' do
      let (:current_user) { create(:user, customer: my_customer)}

      it 'should update vehicles attributes except customer' do
        denver = create(:location, name: 'Denver')
        vehicle = create(:vehicle, customer: my_customer)
        attributes =
          {
            'id' => vehicle.id,
            'vehicle_number' => '123',
            'vin' => '12345678901234567',
            'license_plate' => '111',
            'year' => '1989',
            'make' => 'Hyundai',
            'vehicle_model' => 'Hybrid',
            'mileage' => '123000',
            'location_id' => denver.id
          }

        success = VehicleService.new.update_vehicle(vehicle, attributes)
        success.should be_true

        vehicle.reload
        vehicle.vehicle_number.should == '123'
        vehicle.vin.should == '12345678901234567'
        vehicle.license_plate.should == '111'
        vehicle.year.should == 1989
        vehicle.make.should == 'Hyundai'
        vehicle.vehicle_model.should == 'Hybrid'
        vehicle.mileage.should == 123000
        vehicle.location.should == denver
        vehicle.customer.should == my_customer
      end

      it 'should handle punctuation in mileage' do
        vehicle = create(:vehicle, mileage: 0, customer: my_customer)
        attributes =
          {
            'id' => vehicle.id,
            'mileage' => '123,000.50'
          }

        VehicleService.new.update_vehicle(vehicle, attributes)

        vehicle.reload
        vehicle.mileage.should == 123000
      end

      it 'should return false if errors' do
        vehicle = create(:vehicle, customer: my_customer)
        vehicle.stub(:save).and_return(false)

        success = VehicleService.new.update_vehicle(vehicle, {})
        success.should be_false

        vehicle.reload
      end
    end
  end

  describe '#delete_vehicle' do
    it 'destroys the requested vehicle' do
      vehicle = create(:vehicle, customer: my_customer)

      expect {
        VehicleService.new.delete_vehicle(vehicle)
      }.to change(Vehicle, :count).by(-1)
    end
  end
end