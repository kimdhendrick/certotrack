require 'spec_helper'

describe ServiceType do
  let(:service_type) { build(:service_type) }

  subject { service_type }

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:customer_id) }
  it { should validate_presence_of :expiration_type }
  it { should belong_to :customer }

  it 'should only accept valid interval dates' do
    build(:service_type, interval_date: Interval::ONE_MONTH.text).should be_valid
    build(:service_type, interval_date: Interval::THREE_MONTHS.text).should be_valid
    build(:service_type, interval_date: Interval::SIX_MONTHS.text).should be_valid
    build(:service_type, interval_date: Interval::ONE_YEAR.text).should be_valid
    build(:service_type, interval_date: Interval::TWO_YEARS.text).should be_valid
    build(:service_type, interval_date: Interval::FIVE_YEARS.text).should be_valid
    build(:service_type, interval_date: Interval::NOT_REQUIRED.text).should be_valid

    build(:service_type, interval_date: 'blah').should_not be_valid
  end

  it 'should only accept valid interval mileages' do
    build(:service_type, interval_mileage: 3000).should be_valid
    build(:service_type, interval_mileage: 5000).should be_valid
    build(:service_type, interval_mileage: 10000).should be_valid

    build(:service_type, interval_mileage: 50000).should_not be_valid
  end

  it 'should only accept valid expiration types' do
    build(:service_type, expiration_type: 'By Date').should be_valid
    build(:service_type, expiration_type: 'By Mileage').should be_valid
    build(:service_type, expiration_type: 'By Date and Mileage').should be_valid

    build(:service_type, expiration_type: 'By guess').should_not be_valid
  end

  it 'should require one of interval_date or interval_mileage' do
    service_type = build(:service_type, interval_mileage: nil, interval_date: nil)

    service_type.should_not be_valid
    service_type.errors.full_messages_for(:interval_date).should == ['Interval date or mileage required']
    service_type.errors.full_messages_for(:interval_mileage).should == ['Interval mileage or date required']
  end
end