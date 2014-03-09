require 'spec_helper'

describe VehicleService do
  let(:my_customer) { create(:customer) }

  describe '#get_all_vehicles' do
    let!(:my_vehicle) { create(:vehicle, customer: my_customer) }
    let!(:other_vehicle) { create(:vehicle) }

    context 'when admin user' do
      it 'should return all vehicles' do
        admin_user = create(:user, admin: true)

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
      let (:current_user) { create(:user, customer: my_customer) }

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

  describe '#search_vehicles' do
    let(:my_user) { create(:user, customer: my_customer) }

    context 'search' do
      it 'should call SearchService to filter results' do
        fake_search_service = Faker.new
        vehicle_service = VehicleService.new(search_service: fake_search_service)

        vehicle_service.search_vehicles(my_user, {make: 'Ford'})

        fake_search_service.received_message.should == :search
        fake_search_service.received_params[0].should == []
        fake_search_service.received_params[1].should == {make: 'Ford'}
      end
    end

    context 'an admin user' do
      it 'should return all vehicles' do
        admin_user = create(:user, admin: true)
        my_vehicle = create(:vehicle, customer: my_customer)
        other_vehicle = create(:vehicle)

        VehicleService.new.search_vehicles(admin_user, {}).should == [my_vehicle, other_vehicle]
      end
    end

    context 'a regular user' do
      it "should return only that user's vehicles" do
        my_vehicle = create(:vehicle, customer: my_customer)
        other_vehicle = create(:vehicle)

        VehicleService.new.search_vehicles(my_user, {}).should == [my_vehicle]
      end
    end
  end

  describe '#get_vehicle_makes' do
    it "should only return own customer's vehicle models" do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:vehicle, make: 'my_vehicle', customer: my_customer)
      create(:vehicle, make: 'not_my_vehicle', customer: create(:customer))

      VehicleService.new.get_vehicle_makes(me, 'vehicle').should == ['my_vehicle']
    end

    it 'should not return duplicate models' do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:vehicle, make: 'my_vehicle', customer: my_customer)
      create(:vehicle, make: 'my_vehicle', customer: my_customer)

      VehicleService.new.get_vehicle_makes(me, 'vehicle').should == ['my_vehicle']
    end

    it 'should match term anywhere in model' do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:vehicle, make: 'vehicle_end', customer: my_customer)
      create(:vehicle, make: 'beginning_vehicle_end', customer: my_customer)
      create(:vehicle, make: 'beginning_vehicle', customer: my_customer)

      VehicleService.new.get_vehicle_makes(me, 'vehicle').should =~
        ['vehicle_end', 'beginning_vehicle_end', 'beginning_vehicle']
    end
  end

  describe '#get_vehicle_models' do
    it "should only return own customer's vehicle makes" do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:vehicle, vehicle_model: 'my_vehicle', customer: my_customer)
      create(:vehicle, vehicle_model: 'not_my_vehicle', customer: create(:customer))

      VehicleService.new.get_vehicle_models(me, 'vehicle').should == ['my_vehicle']
    end

    it 'should not return duplicate makes' do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:vehicle, vehicle_model: 'my_vehicle', customer: my_customer)
      create(:vehicle, vehicle_model: 'my_vehicle', customer: my_customer)

      VehicleService.new.get_vehicle_models(me, 'vehicle').should == ['my_vehicle']
    end

    it 'should match term anywhere in model' do
      my_customer = create(:customer)
      me = create(:user, customer: my_customer)
      create(:vehicle, vehicle_model: 'vehicle_end', customer: my_customer)
      create(:vehicle, vehicle_model: 'beginning_vehicle_end', customer: my_customer)
      create(:vehicle, vehicle_model: 'beginning_vehicle', customer: my_customer)

      VehicleService.new.get_vehicle_models(me, 'vehicle').should =~
        ['vehicle_end', 'beginning_vehicle_end', 'beginning_vehicle']
    end
  end

  describe '#get_all_non_serviced_vehicles_for' do
    context 'when regular user' do
      it 'should return empty list when no vehicles' do
        service_type = create(:service_type, customer: my_customer)
        
        VehicleService.new.get_all_non_serviced_vehicles_for(service_type).should == []
      end

      it 'should return empty list when all vehicles certified' do
        service_type = create(:service_type, customer: my_customer)
        certified_vehicle1 = create(:vehicle, customer: my_customer)
        certified_vehicle2 = create(:vehicle, customer: my_customer)
        create(:service, vehicle: certified_vehicle1, service_type: service_type, customer: my_customer)
        create(:service, vehicle: certified_vehicle2, service_type: service_type, customer: my_customer)

        VehicleService.new.get_all_non_serviced_vehicles_for(service_type).should == []
      end

      it "should return only customer's vehicles" do
        service_type = create(:service_type, customer: my_customer)
        my_vehicle = create(:vehicle, customer: my_customer)
        other_vehicle = create(:vehicle)

        VehicleService.new.get_all_non_serviced_vehicles_for(service_type).should == [my_vehicle]
      end

      it 'only returns uncertified vehicles' do
        service_type = create(:service_type, customer: my_customer)
        certified_vehicle = create(:vehicle, vehicle_model: 'certified', customer: my_customer)
        create(:service, vehicle: certified_vehicle, service_type: service_type, customer: my_customer)
        uncertified_vehicle = create(:vehicle, vehicle_model: 'UNCERTIFIED', customer: my_customer)

        VehicleService.new.get_all_non_serviced_vehicles_for(service_type).should == [uncertified_vehicle]
      end

      it 'should return all vehicles' do
        service_type = create(:service_type, customer: my_customer)
        uncertified_vehicle1 = create(:vehicle, customer: my_customer)
        uncertified_vehicle2 = create(:vehicle, customer: my_customer)
        VehicleService.new.get_all_non_serviced_vehicles_for(service_type).should == [uncertified_vehicle1, uncertified_vehicle2]
      end
    end

    context 'when admin user should still limit to customer' do
      it "should return only customer's vehicles" do
        service_type = create(:service_type, customer: my_customer)
        my_vehicle = create(:vehicle, customer: my_customer)
        other_vehicle = create(:vehicle)

        VehicleService.new.get_all_non_serviced_vehicles_for(service_type).should == [my_vehicle]
      end

      it 'only returns uncertified vehicles' do
        service_type = create(:service_type, customer: my_customer)
        certified_vehicle = create(:vehicle, vehicle_model: 'certified', customer: my_customer)
        create(:service, vehicle: certified_vehicle, service_type: service_type, customer: my_customer)
        uncertified_vehicle = create(:vehicle, vehicle_model: 'UNCERTIFIED', customer: my_customer)

        VehicleService.new.get_all_non_serviced_vehicles_for(service_type).should == [uncertified_vehicle]
      end
    end
  end
end