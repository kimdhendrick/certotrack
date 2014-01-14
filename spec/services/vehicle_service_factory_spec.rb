require 'spec_helper'

describe VehicleServiceFactory do
  describe 'new_instance' do
    it 'creates a service when given no service data' do
      customer = create(:customer)
      service = VehicleServiceFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id
      )

      service.should_not be_persisted
      service.errors.should be_empty
      service.customer.should == customer
    end

    it 'should only have one error on blank start date' do
      customer = create(:customer)
      service = VehicleServiceFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id
      )

      service.valid?
      service.active_service_period.valid?

      service.errors.full_messages_for(:"active_service_period.start_date").first.should == 'Last service date is not a valid date'
      service.errors.full_messages_for(:"service_periods.start_date").should be_empty
    end

    it 'creates a service when given an vehicle_id' do
      service_type = create(:service_type)
      customer = create(:customer)
      vehicle = create(:vehicle)

      service = VehicleServiceFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id,
        vehicle_id: vehicle.id,
        service_type_id: service_type.id,
        service_date: '12/30/2000',
        service_mileage: '4200',
        comments: 'Great class!'
      )

      service.should_not be_persisted
      service.vehicle.should == vehicle
      service.customer.should == customer
      service.service_type.should == service_type
      service.active_service_period.comments.should == 'Great class!'
      service.last_service_date.should == Date.new(2000, 12, 30)
      service.last_service_mileage.should == 4200
    end

    it 'creates a service when given a service_type_id' do
      customer = create(:customer)
      service_type = create(:service_type)

      service = VehicleServiceFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id,
        vehicle_id: nil,
        service_type_id: service_type.id
      )

      service.should_not be_persisted
      service.customer.should == customer
      service.service_type.should == service_type
    end

    it 'creates a service without errors' do
      customer = create(:customer)
      service = VehicleServiceFactory.new.new_instance(
        current_user_id: create(:user, customer: customer).id
      )

      service.errors.should be_empty
    end

    it 'handles bad date' do
      service_type = create(:service_type)
      vehicle = create(:vehicle)

      service = VehicleServiceFactory.new.new_instance(
        current_user_id: create(:user).id,
        vehicle_id: vehicle.id,
        service_type_id: service_type.id,
        service_date: '999',
        comments: 'Great class!'
      )

      service.should_not be_persisted
      service.should_not be_valid
      service.active_service_period.should_not be_valid
      service.vehicle.should == vehicle
      service.service_type.should == service_type
      service.active_service_period.comments.should == 'Great class!'
      service.last_service_date.should == nil
    end

    it 'calculates expiration date using calculator' do
      service_type = create(:service_type, interval_date: Interval::ONE_MONTH.text)
      vehicle = create(:vehicle)
      fake_expiration_date = Date.new(2001, 1, 15)

      service_factory = VehicleServiceFactory.new

      service = service_factory.new_instance(
        current_user_id: create(:user).id,
        vehicle_id: vehicle.id,
        service_type_id: service_type.id,
        service_date: '12/15/2000',
        comments: nil
      )

      service.expiration_date.should == fake_expiration_date
    end

    it 'calculates expiration mileage using calculator' do
      service_type = create(:service_type, interval_mileage: 15000)
      vehicle = create(:vehicle)
      fake_expiration_calculator = Faker.new(45000)
      service_factory = VehicleServiceFactory.new(expiration_calculator: fake_expiration_calculator)

      service = service_factory.new_instance(
        current_user_id: create(:user).id,
        vehicle_id: vehicle.id,
        service_type_id: service_type.id,
        service_date: '12/15/2000',
        service_mileage: 20000,
        comments: nil
      )

      fake_expiration_calculator.received_messages.should include(:calculate_mileage)
      fake_expiration_calculator.received_params[0].should == 20000
      fake_expiration_calculator.received_params[1].should == 15000
      service.expiration_mileage.should == 45000
    end
  end
end