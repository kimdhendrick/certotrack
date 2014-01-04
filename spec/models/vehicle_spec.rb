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
    it 'should return N/A for now' do
      vehicle.status.should == Status::NA
    end
  end

  # Status:
  #def getStatus() {
  #  def vehicleServices = Maintenance.findAllByVehicle(this)
  #  if (!vehicleServices) {
  #    return Status.NA
  #  }
  #  vehicleServices.any{ it.status == Status.EXPIRED } ? Status.EXPIRED : vehicleServices.max { it.status }.status
  #  }
end