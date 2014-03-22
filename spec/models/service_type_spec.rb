require 'spec_helper'

describe ServiceType do
  let(:service_type) { build(:service_type) }

  subject { service_type }

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:customer_id) }
  it { should validate_presence_of :expiration_type }
  it { should validate_presence_of :customer }
  it { should validate_presence_of :created_by }
  it { should belong_to :customer }
  it { should have_many :services }

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
    build(:service_type, interval_mileage: 12000).should be_valid
    build(:service_type, interval_mileage: 15000).should be_valid
    build(:service_type, interval_mileage: 20000).should be_valid
    build(:service_type, interval_mileage: 50000).should be_valid

    build(:service_type, interval_mileage: 123000).should_not be_valid
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

  it 'should answer mileage_expiration_type?' do
    service_type_date_type = build(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
    service_type_date_or_mileage_type = build(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE)
    service_type_mileage_type = build(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE)

    service_type_mileage_type.mileage_expiration_type?.should be_true
    service_type_date_or_mileage_type.mileage_expiration_type?.should be_true
    service_type_date_type.mileage_expiration_type?.should be_false
  end

  it 'should answer date_expiration_type?' do
    service_type_date_type = build(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
    service_type_date_or_mileage_type = build(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE)
    service_type_mileage_type = build(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE)

    service_type_date_or_mileage_type.date_expiration_type?.should be_true
    service_type_date_type.date_expiration_type?.should be_true
    service_type_mileage_type.date_expiration_type?.should be_false
  end

  describe '#destroy' do
    before { service_type.save }

    context 'when service type has no services' do
      it 'should destroy service type' do
        expect { service_type.destroy }.to change(ServiceType, :count).by(-1)
      end
    end

    context 'when service type has one or more services' do
      before { create(:service, service_type: service_type) }

      it 'should not destroy service_type' do
        expect { service_type.destroy }.to_not change(ServiceType, :count).by(-1)
      end

      it 'should have a base error' do
        service_type.destroy

        service_type.errors[:base].first.should == 'This Service Type is assigned to existing Vehicle(s). You must remove the vehicle assignment(s) before removing it.'
      end
    end
  end
end