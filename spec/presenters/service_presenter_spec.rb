require 'spec_helper'

describe ServicePresenter do

  let(:service) do
    service_type = create(:service_type,
                          name: 'Oil Change',
                          expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
                          interval_date: Interval::ONE_MONTH.text,
                          interval_mileage: 5000,
                          customer: create(:customer, name: 'myCustomer'))

    vehicle = create(:vehicle,
                     make: 'Ford',
                     vehicle_model: 'Edge',
                     year: 2009,
                     mileage: 10000,
                     vehicle_number: '123123',
                     vin: '12312312312312312',
                     location: create(:location, name: 'Golden'),
                     license_plate: 'GLI',
                     customer: service_type.customer)

    build(:service,
          service_type: service_type,
          vehicle: vehicle,
          last_service_date: Date.new(2000, 1, 1),
          last_service_mileage: 7000,
          expiration_date: Date.new(2000, 6, 1),
          expiration_mileage: 10000,
          customer: service_type.customer)
  end

  subject { ServicePresenter.new(service) }

  it 'should respond to model' do
    subject.model.should == service
  end

  it 'should respond to id' do
    subject.id.should == service.id
  end

  it 'should respond to service_type_name' do
    subject.service_type_name.should == 'Oil Change'
  end

  it 'should respond to service_due_date' do
    subject.service_due_date.should == '06/01/2000'
  end

  it 'should respond to service_due_mileage' do
    subject.service_due_mileage.should == '10,000'
  end

  it 'should respond to last_service_date' do
    subject.last_service_date.should == '01/01/2000'
  end

  it 'should respond to last_service_mileage' do
    subject.last_service_mileage.should == '7,000'
  end

  it 'should respond to sort_key' do
    subject.sort_key.should == 'Oil Change'
  end

  it 'should respond to vehicle_number' do
    subject.vehicle_number.should == '123123'
  end

  it 'should respond to vehicle_vin' do
    subject.vehicle_vin.should == '12312312312312312'
  end

  it 'should respond to vehicle_license_plate' do
    subject.vehicle_license_plate.should == 'GLI'
  end

  it 'should respond to vehicle_year' do
    subject.vehicle_year.should == 2009
  end

  it 'should respond to vehicle_make' do
    subject.vehicle_make.should == 'Ford'
  end

  it 'should respond to vehicle_model' do
    subject.vehicle_model.should == 'Edge'
  end

  it 'should respond to mileage' do
    subject.vehicle_mileage.should == '10,000'
  end

  it 'should respond to location' do
    subject.vehicle_location.should == 'Golden'
  end

  it 'should respond to status' do
    subject.status.should == 'Expired'
  end
end