require 'spec_helper'

describe VehicleServicingService do
  describe '#new_service' do
    it 'calls vehicle_service_factory' do
      user = create(:user)
      vehicle = create(:vehicle)
      service_type = create(:service_type)
      service = build(:service, vehicle: vehicle)
      fake_service_factory = Faker.new(service)
      service_service = VehicleServicingService.new(vehicle_service_factory: fake_service_factory)

      service = service_service.new_vehicle_service(user, vehicle.id, service_type.id)

      fake_service_factory.received_message.should == :new_instance
      fake_service_factory.received_params[0][:current_user_id].should == user.id
      fake_service_factory.received_params[0][:vehicle_id].should == vehicle.id
      fake_service_factory.received_params[0][:service_type_id].should == vehicle.id
      service.should_not be_persisted
    end
  end

  describe '#service_vehicle' do
    it 'creates a service' do
      vehicle = create(:vehicle)
      service_type = create(:service_type)
      service = build(:service, service_type: service_type, vehicle: vehicle)
      fake_service_factory = Faker.new(service)
      vehicle_servicing_service = VehicleServicingService.new(vehicle_service_factory: fake_service_factory)

      service = vehicle_servicing_service.service_vehicle(
        create(:user),
        vehicle.id,
        service_type.id,
        '12/31/2000',
        '32000',
        'Great service!'
      )

      fake_service_factory.received_message.should == :new_instance
      fake_service_factory.received_params[0][:vehicle_id].should == vehicle.id
      fake_service_factory.received_params[0][:service_type_id].should == service_type.id
      fake_service_factory.received_params[0][:service_date].should == '12/31/2000'
      fake_service_factory.received_params[0][:service_mileage].should == '32000'
      fake_service_factory.received_params[0][:comments].should == 'Great service!'
      service.should be_persisted
    end

    it 'handles bad date' do
      vehicle = create(:vehicle)
      service_type = create(:service_type)
      service = Service.new
      fake_service_factory = Faker.new(service)
      vehicle_servicing_service = VehicleServicingService.new(vehicle_service_factory: fake_service_factory)

      service = vehicle_servicing_service.service_vehicle(
        create(:user),
        vehicle.id,
        service_type.id,
        '999',
        '32000',
        'Great service!'
      )

      service.should_not be_valid
      service.should_not be_persisted
      fake_service_factory.received_message.should == :new_instance
      fake_service_factory.received_params[0][:vehicle_id].should == vehicle.id
      fake_service_factory.received_params[0][:service_type_id].should == service_type.id
      fake_service_factory.received_params[0][:service_date].should == '999'
      fake_service_factory.received_params[0][:service_mileage].should == '32000'
      fake_service_factory.received_params[0][:comments].should == 'Great service!'
    end
  end

  describe '#get_all_services_for_vehicle' do
    it 'returns all services for a given vehicle' do
      vehicle_1 = create(:vehicle)
      vehicle_2 = create(:vehicle)
      service_1 = create(:service, vehicle: vehicle_1)
      service_2 = create(:service, vehicle: vehicle_2)

      subject = VehicleServicingService.new

      subject.get_all_services_for_vehicle(vehicle_1).should == [service_1]
      subject.get_all_services_for_vehicle(vehicle_2).should == [service_2]
    end
  end
end