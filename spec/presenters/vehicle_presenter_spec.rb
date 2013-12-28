require 'spec_helper'

describe VehiclePresenter do

  let(:vehicle) do
    build(:vehicle,
          vehicle_number: '1000',
          make: 'Honda',
          vehicle_model: 'Civic',
          vin: '12345678901234567',
          license_plate: 'HAPPYONE',
          mileage: 200000,
          year: 2009,
          customer: create(:customer, name: 'myCustomer'))
  end

  subject { VehiclePresenter.new(create(:vehicle)) }
  it_behaves_like 'an object that is sortable by status'

  it 'should respond to model' do
    VehiclePresenter.new(vehicle).model.should == vehicle
  end

  it 'should respond to id' do
    VehiclePresenter.new(vehicle).id.should == vehicle.id
  end

  it 'should respond to vehicle_number' do
    VehiclePresenter.new(vehicle).vehicle_number.should == '1000'
  end

  it 'should respond to vin' do
    VehiclePresenter.new(vehicle).vin.should == '12345678901234567'
  end

  it 'should respond to license_plate' do
    VehiclePresenter.new(vehicle).license_plate.should == 'HAPPYONE'
  end

  it 'should respond to make' do
    VehiclePresenter.new(vehicle).make.should == 'Honda'
  end

  it 'should respond to vehicle_model' do
    VehiclePresenter.new(vehicle).vehicle_model.should == 'Civic'
  end

  it 'should respond to year' do
    VehiclePresenter.new(vehicle).year.should == 2009
  end

  it 'should respond to mileage' do
    VehiclePresenter.new(vehicle).mileage.should == '200,000'
  end

  it 'should respond to sortable_mileage' do
    VehiclePresenter.new(vehicle).sortable_mileage.should == 200000
  end

  it 'should respond to location' do
    location = create(:location, name: 'Florida')
    location_assigned_vehicle = create(:vehicle, location: location)

    VehiclePresenter.new(location_assigned_vehicle).location.should == 'Florida'
  end

  it 'should respond to location when unassigned' do
    unassigned_vehicle = create(:vehicle, location: nil)
    VehiclePresenter.new(unassigned_vehicle).location.should == 'Unassigned'
  end

  it 'should respond to sort_key' do
    VehiclePresenter.new(vehicle).sort_key.should == '1000'
  end

  it 'should respond to name when all the info populated' do
    vehicle = create(
      :vehicle,
      license_plate: 'GET-REAL',
      vehicle_number: '123',
      year: 2013,
      vehicle_model: 'Endeavor'
    )

    VehiclePresenter.new(vehicle).name.should == 'GET-REAL/123 2013 Endeavor'
  end

  it 'should respond to name when missing year' do
    vehicle = create(
      :vehicle,
      license_plate: 'GET-REAL',
      vehicle_number: '123',
      vehicle_model: 'Endeavor',
      year: nil
    )

    VehiclePresenter.new(vehicle).name.should == 'GET-REAL/123 Endeavor'
  end

  it 'should respond to name when missing model' do
    vehicle = create(
      :vehicle,
      license_plate: 'GET-REAL',
      vehicle_number: '123',
      year: 2013,
      vehicle_model: nil
    )

    VehiclePresenter.new(vehicle).name.should == 'GET-REAL/123 2013'
  end

  it 'should respond to name when missing all optional data' do
    vehicle = create(
      :vehicle,
      license_plate: 'GET-REAL',
      vehicle_number: '123',
      year: nil,
      vehicle_model: nil,
      make: nil
    )

    VehiclePresenter.new(vehicle).name.should == 'GET-REAL/123'
  end

  #String toString() {
  #  (_getDescription() + ' ' +  year + ' ' + _toText(model)).trim()
  #}
  #
  #private _getDescription() {
  #  licensePlate && carNumber ?
  #    licensePlate + '/' + carNumber :
  #    _toText(licensePlate) + _toText(carNumber)
  #}
  #
  #private _toText(value) {
  #  value ?: ''
  #}

end