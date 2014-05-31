require 'spec_helper'

describe ServicePeriod do
  let(:service_type) { create(:service_type) }
  let(:service) { create(:service, service_type: service_type) }
  subject { ServicePeriod.new(start_date: Date.new(2013, 9, 6), service: service) }

  it { should belong_to(:service) }

  it 'should validate presence of start_date and start_mileage if expiration_type is empty' do
    subject.service.service_type.expiration_type = nil
    subject.start_date = nil
    subject.start_mileage = nil

    subject.valid?

    subject.errors[:start_date].should == ['is not a valid date']
    subject.errors[:start_mileage].should include "can't be blank"
  end

  context 'date based' do
    it 'should validate presence of start_date if date based' do
      subject.service.service_type.expiration_type = ServiceType::EXPIRATION_TYPE_BY_DATE
      subject.start_date = nil

      subject.valid?

      subject.errors[:start_date].should == ['is not a valid date']
    end

    it 'should not validate presence of start_mileage if not mileage based' do
      subject.service.service_type.expiration_type = ServiceType::EXPIRATION_TYPE_BY_DATE
      subject.start_mileage = nil

      subject.valid?

      subject.errors[:start_mileage].should be_empty
    end
  end

  context 'mileage based' do
    it 'should not validate presence of start_date if not date based' do
      subject.service.service_type.expiration_type = ServiceType::EXPIRATION_TYPE_BY_MILEAGE
      subject.start_date = nil

      subject.valid?

      subject.errors[:start_date].should be_empty
    end

    it 'should validate presence of start_mileage if mileage based' do
      subject.service.service_type.expiration_type = ServiceType::EXPIRATION_TYPE_BY_MILEAGE
      subject.start_mileage = nil

      subject.valid?

      subject.errors[:start_mileage].should include "can't be blank"
    end

    describe 'start mileage' do
      it 'should not allow negative mileage' do
        subject.start_mileage = -1
        subject.should_not be_valid
        subject.errors[:start_mileage].should == ['must be greater than or equal to 0']
      end

      it 'should not allow non-numeric mileage' do
        subject.start_mileage = 'abc'
        subject.should_not be_valid
        subject.errors[:start_mileage].should == ['is not a number']
      end

      it 'should allow positive mileage' do
        subject.start_mileage = 1
        subject.should be_valid
      end

      it 'should allow 0 mileage' do
        subject.start_mileage = 0
        subject.should be_valid
      end
    end
  end

  context 'date and mileage based' do
    it 'should validate presence of start_mileage and start_date if date and mileage based' do
      subject.service.service_type.expiration_type = ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE
      subject.start_date = nil
      subject.start_mileage = nil

      subject.valid?

      subject.errors[:start_mileage].should include "can't be blank"
      subject.errors[:start_date].should == ['is not a valid date']
    end
  end

  describe 'new date validations' do
    subject do
      service = create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE))
      ServicePeriod.new(start_date: Date.today, start_mileage: 0, service: service)
    end

    before { Timecop.freeze(2013, 9, 6) }
    after { Timecop.return }

    it { should be_valid }

    it 'should give invalid date if date is more than 100 years in the future' do
      subject.start_date = 101.years.from_now
      subject.should_not be_valid
      subject.errors[:start_date].should == ['out of range']
    end

    it 'should give invalid date if date is more than 100 years in the past' do
      subject.start_date = 101.years.ago
      subject.should_not be_valid
      subject.errors[:start_date].should == ['out of range']
    end
  end
end
