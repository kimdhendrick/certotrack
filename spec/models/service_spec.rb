require 'spec_helper'

describe Service do

  it { should belong_to(:customer) }
  it { should belong_to(:service_type) }
  it { should belong_to(:vehicle) }
  it { should belong_to(:active_service_period) }
  it { should validate_presence_of :active_service_period }
  it { should validate_presence_of :service_type }
  it { should validate_presence_of :vehicle }
  it { should validate_presence_of :customer }

  it 'should validate the uniqueness of service_type_id' do
    service = create(:service)
    service.should validate_uniqueness_of(:service_type_id).
                     scoped_to(:vehicle_id).
                     with_message(/already assigned to this Vehicle. Please update existing Service/)

  end

  context 'date based expiration type' do
    let (:service_type) { create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE) }
    let (:service) { build(:service, service_type: service_type) }
    let (:service_period) { create(:service_period, service: service) }

    it 'should calculate NA status when no expiration date' do
      service.expiration_date = nil

      service.status.should == Status::NA
    end

    it 'should calculate VALID status when expiration date is in the future' do
      service.expiration_date = Date.today + 61.days

      service.status.should == Status::VALID
    end

    it 'should calculate EXPIRED status when expiration date is in the past' do
      service.expiration_date = Date.yesterday

      service.status.should == Status::EXPIRED
    end

    it 'should calculate WARNING status when expiration date is within 60 days in the future' do
      service.expiration_date = Date.tomorrow

      service.status.should == Status::EXPIRING
    end

    it 'should answer expired? when expired' do
      service.expiration_date = Date.yesterday

      service.should be_expired
    end

    it 'should answer expired? when not expired' do
      service.expiration_date = Date.tomorrow

      service.should_not be_expired
    end

    it 'should answer expiring? when expiring' do
      service.expiration_date = Date.tomorrow

      service.should be_expiring
    end

    it 'should answer expiring? when not expiring' do
      service.expiration_date = Date.today

      service.should_not be_expiring
    end
  end

  context 'mileage based expiration type' do
    let (:service_type) { create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE) }
    let (:vehicle) { build(:vehicle, mileage: 10000) }
    let (:service) { build(:service, service_type: service_type, vehicle: vehicle) }
    let (:service_period) { create(:service_period, service: service) }

    it 'should calculate NA status when no expiration mileage' do
      service.expiration_mileage = nil

      service.status.should == Status::NA
    end

    it 'should calculate VALID status when expiration mileage is in the future' do
      service.expiration_mileage = 20000

      service.status.should == Status::VALID
    end

    it 'should calculate EXPIRED status when expiration mileage past' do
      service.expiration_mileage = 5000

      service.status.should == Status::EXPIRED
    end

    it 'should calculate WARNING status when expiration mileage is within 500 miles' do
      service.expiration_mileage = 10499

      service.status.should == Status::EXPIRING
    end

    it 'should answer expired? when expired' do
      service.expiration_mileage = 5000

      service.should be_expired
    end

    it 'should answer expired? when not expired' do
      service.expiration_mileage = 20000

      service.should_not be_expired
    end

    it 'should answer expiring? when expiring' do
      service.expiration_mileage = 10499

      service.should be_expiring
    end

    it 'should answer expiring? when not expiring' do
      service.expiration_mileage = 20000

      service.should_not be_expiring
    end
  end

  context 'date and mileage based expiration type' do

  end

  let (:service_type) { create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE) }

  it 'should respond to status_code for sorting' do
    service = build(:service, service_type: service_type)

    service.status_code.should == service.status.sort_order
  end

  it 'should respond to active_service_period' do
    service = create(:service)

    service.active_service_period.should be_a(ServicePeriod)
  end

  it 'should respond to last_service_date' do
    service = create(:service)
    service.active_service_period.start_date = Date.new(2010, 5, 10)

    service.last_service_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to last_service_date=' do
    service = create(:service)
    service.last_service_date = Date.new(2010, 5, 10)

    service.last_service_date.should == Date.new(2010, 5, 10)
    service.active_service_period.start_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to expiration_date' do
    service = create(:service)
    service.active_service_period.end_date = Date.new(2012, 1, 2)

    service.expiration_date.should == Date.new(2012, 1, 2)
  end

  it 'should respond to expiration_date=' do
    service = create(:service)
    service.expiration_date = Date.new(2010, 5, 10)

    service.expiration_date.should == Date.new(2010, 5, 10)
    service.active_service_period.end_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to comments' do
    service = create(:service)
    service.active_service_period.comments= 'something special'

    service.comments.should == 'something special'
  end

  it 'should respond to comments=' do
    service = create(:service)
    service.comments = 'Hiya'

    service.comments.should == 'Hiya'
    service.active_service_period.comments.should == 'Hiya'
  end

  it 'should respond to name' do
    service_type = create(:service_type, name: 'Scrum Master')
    service = create(:service, service_type: service_type)
    service.name.should == 'Scrum Master'
  end

  it 'should respond to interval_date' do
    service_type = create(:service_type, interval_date: Interval::THREE_MONTHS.text)
    service = create(:service, service_type: service_type)
    service.interval_date.should == '3 months'
  end

  it 'should respond to interval_mileage' do
    service_type = create(:service_type, interval_mileage: 15000)
    service = create(:service, service_type: service_type)
    service.interval_mileage.should == 15000
  end

  it 'should respond to expiration_type' do
    service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE)
    service = create(:service, service_type: service_type)
    service.expiration_type.should == ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE
  end

  it 'should respond to date_expiration_type?' do
    service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
    service = create(:service, service_type: service_type)
    service.date_expiration_type?.should be_true
  end

  it 'should respond to mileage_expiration_type?' do
    service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE)
    service = create(:service, service_type: service_type)
    service.mileage_expiration_type?.should be_true
  end

  describe 'new date validations' do
    subject { Service.new }
    let(:service_period) do
      service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
      ServicePeriod.new(start_date: start_date, service: create(:service, service_type: service_type))
    end

    before do
      subject.active_service_period = service_period
      subject.valid?
    end

    before { Timecop.freeze(2013, 9, 6) }
    after { Timecop.return }

    context 'when start_date is invalid' do
      let(:start_date) { '1111111' }

      it 'should have the correct message' do
        subject.errors.full_messages_for(:'active_service_period.start_date').first.should == 'Last service date is not a valid date'
      end
    end

    context 'when start_date is more than 100 years in the future' do
      let(:start_date) { 101.years.from_now }

      it 'should have the correct message' do
        subject.errors.full_messages_for(:'active_service_period.start_date').first.should == 'Last service date out of range'
      end
    end

    context 'when start_date is more than 100 years in the past' do
      let(:start_date) { 101.years.ago }

      it 'should have the correct message' do
        subject.errors.full_messages_for(:'active_service_period.start_date').first.should == 'Last service date out of range'
      end
    end
  end

  describe 'service_period validation' do
    context 'when start_date is not after last_service_date' do
      it 'should have correct message' do
        service = create(:service, last_service_date: 1.day.ago)
        service.reload

        service.reservice(start_date: 1.year.ago)

        service.should_not be_valid
        service.errors.full_messages_for(:last_service_date).first.should == 'Last service date must be after previous Last service date'
      end
    end
  end

  it_behaves_like 'an object that is sortable by status'

  describe '#reservice' do
    subject do
      service_type = create(
        :service_type,
        expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
        interval_date: Interval::ONE_YEAR.text
      )

      create(:service, last_service_date: 1.year.ago, service_type: service_type)
    end

    let(:start_date) { 2.days.from_now }
    let(:comments) { 'New Comments' }
    let(:attributes) { {start_date: start_date, comments: comments} }

    before do
      @original_service_period = subject.active_service_period
      Timecop.freeze(Time.local(2013, 10, 20, 18, 16, 00))
    end

    after { Timecop.return }

    it 'should keep the original service period in its history' do
      subject.reload
      subject.reservice(attributes)
      subject.service_periods.should include(@original_service_period)
    end

    it 'should create a new active_service_period' do
      subject.reload
      subject.reservice(attributes)
      subject.active_service_period.should_not == @original_service_period
    end

    it 'should set new start_date in active_service_period' do
      subject.reservice(start_date: start_date)
      subject.last_service_date.should == start_date
    end

    it 'should set new comments in active_service_period' do
      subject.reservice(comments: comments)
      subject.active_service_period.comments.should == comments
    end

    it 'should create a valid active_service_period' do
      subject.reservice(attributes)
      subject.active_service_period.should be_valid
    end

    it 'should recalculate expiration_date' do
      subject.reservice(attributes)
      subject.expiration_date.should == Time.utc(2014, 10, 23, 0, 16, 0)
    end
  end
end