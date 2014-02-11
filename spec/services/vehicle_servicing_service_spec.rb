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

  describe '#get_all_services_for_service_type' do
    it 'returns all services for a given service_type' do
      service_type_1 = create(:service_type)
      service_type_2 = create(:service_type)
      service_1 = create(:service, service_type: service_type_1)
      service_2 = create(:service, service_type: service_type_2)

      subject = VehicleServicingService.new

      subject.get_all_services_for_service_type(service_type_1).should == [service_1]
      subject.get_all_services_for_service_type(service_type_2).should == [service_2]
    end
  end

  describe '#update_service' do
    it 'should update services attributes' do
      vehicle = create(:vehicle)
      service_type = create(
        :service_type,
        expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE,
        interval_date: Interval::ONE_YEAR.text,
        interval_mileage: 5000
      )

      service = create(:service)
      attributes = {
        'vehicle_id' => vehicle.id,
        'service_type_id' => service_type.id,
        'last_service_date' => '03/05/2013',
        'last_service_mileage' => '10,000',
        'comments' => 'Comments'
      }

      success = VehicleServicingService.new.update_service(service, attributes)
      success.should be_true

      service.reload
      service.vehicle_id.should == vehicle.id
      service.service_type_id.should == service_type.id
      service.last_service_date.should == Date.new(2013, 3, 5)
      service.last_service_mileage.should == 10000
      service.expiration_date.should == Date.new(2014, 3, 5)
      service.expiration_mileage.should == 15000
      service.comments.should == 'Comments'
    end

    it 'should return false if errors' do
      service = create(:service)
      service.stub(:save).and_return(false)

      success = VehicleServicingService.new.update_service(service, {})
      success.should be_false
    end
  end

  describe '#delete_service' do
    it 'destroys the requested service' do
      service = create(:service)
      ServicePeriod.count.should > 0

      expect {
        VehicleServicingService.new.delete_service(service)
      }.to change(Service, :count).by(-1)

      ServicePeriod.count.should == 0
    end
  end

  describe '#reservice' do
    let(:start_date) { Date.current }
    let(:start_mileage) { 10_000 }
    let(:comments) { 'some_comments' }
    let(:attributes) { {start_date: start_date, start_mileage: start_mileage, comments: comments} }
    let(:service) { double('service') }

    subject { VehicleServicingService.new }

    it 'should create and assign a new active service period' do
      service.should_receive(:reservice).with(attributes)
      service.should_receive(:save)

      subject.reservice(service, attributes)
    end
  end

  describe '#count_all_services' do
    let(:customer) { create(:customer) }

    before do
      create(:service, customer: customer)
      create(:service, customer: create(:customer))
    end

    context 'vehicle user' do
      it 'returns count of services for customer' do
        my_user = create(:user, customer: customer)

        VehicleServicingService.new.count_all_services(my_user).should == 1
      end
    end

    context 'admin user' do
      it 'returns count of all services' do
        admin_user = create(:user, roles: ['admin'])

        VehicleServicingService.new.count_all_services(admin_user).should == 2
      end
    end
  end

  describe '#get_all_services' do
    let(:customer) { create(:customer) }

    let(:my_service) { create(:service, customer: customer) }
    let(:other_service) { create(:service, customer: create(:customer)) }

    context 'vehicle user' do
      it 'returns count of services for customer' do
        my_user = create(:user, customer: customer)

        VehicleServicingService.new.get_all_services(my_user).should == [my_service]
      end
    end

    context 'admin user' do
      it 'returns count of all services' do
        admin_user = create(:user, roles: ['admin'])

        VehicleServicingService.new.get_all_services(admin_user).should =~ [my_service, other_service]
      end
    end
  end
end