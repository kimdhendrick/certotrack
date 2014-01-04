require 'spec_helper'

describe Vehicle do
  let(:vehicle) { build(:vehicle) }

  subject { vehicle }

  it { should validate_presence_of :vehicle_number }
  it { should validate_uniqueness_of(:vehicle_number).scoped_to(:customer_id) }
  it { should validate_presence_of :vin }
  it { should validate_uniqueness_of(:vin).scoped_to(:customer_id) }
  it { should ensure_length_of(:vin).is_equal_to(17) }
  it { should validate_presence_of :license_plate }
  it { should validate_uniqueness_of(:license_plate).scoped_to(:customer_id) }
  it { should belong_to :location }
  it { should belong_to :customer }
  it { should have_many :services }

  describe 'when vin has mixed case' do
    let(:vehicle) { create(:vehicle, vin: '1m8GDM9aXKp042788') }

    it 'should uppercase the vin' do
      vehicle.vin.should == '1M8GDM9AXKP042788'
    end
  end

  describe '#status' do
    it 'should return NA when no services assigned to vehicle' do
      vehicle.status.should == Status::NA
    end

    it 'should return VALID when all services assigned to vehicle are VALID' do
      valid_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_MONTH.text)
      create(:service, vehicle: vehicle, service_type: valid_service_type, expiration_date: Date.current+120)

      vehicle.status.should == Status::VALID
    end

    it 'should return EXPIRING when one of the services assigned to vehicle is EXPIRING' do
      valid_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_MONTH.text)
      create(:service, vehicle: vehicle, service_type: valid_service_type, expiration_date: Date.current+120)
      warning_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_MONTH.text)
      create(:service, vehicle: vehicle, service_type: warning_service_type, expiration_date: Date.current+2)

      vehicle.status.should == Status::EXPIRING
    end

    it 'should return EXPIRED when one of the services assigned to vehicle is EXPIRED' do
      na_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_MONTH.text)
      create(:service, vehicle: vehicle, service_type: na_service_type, expiration_date: nil)
      valid_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_MONTH.text)
      create(:service, vehicle: vehicle, service_type: valid_service_type, expiration_date: Date.current+120)
      warning_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_MONTH.text)
      create(:service, vehicle: vehicle, service_type: warning_service_type, expiration_date: Date.current+2)
      expired_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_MONTH.text)
      create(:service, vehicle: vehicle, service_type: expired_service_type, expiration_date: Date.current-2)

      vehicle.status.should == Status::EXPIRED
    end
  end
end