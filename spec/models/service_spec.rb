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
      service.expiration_date = Date.current + 61.days

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
      service.expiration_date = Date.yesterday

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
    let (:service_type) { create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE) }
    let (:vehicle) { build(:vehicle, mileage: 10000) }
    let (:service) { build(:service, service_type: service_type, vehicle: vehicle) }
    let (:service_period) { create(:service_period, service: service) }

    it 'should calculate NA status when no expiration mileage or date' do
      service.expiration_mileage = nil
      service.expiration_date = nil

      service.status.should == Status::NA
    end

    it 'should calculate EXPIRED status when no expiration mileage and date is expired' do
      service.expiration_mileage = nil
      service.expiration_date = Date.yesterday

      service.status.should == Status::EXPIRED
    end

    it 'should calculate EXPIRED status when no expiration date and mileage is expired' do
      service.expiration_mileage = 10
      service.expiration_date = nil

      service.status.should == Status::EXPIRED
    end

    it 'should calculate EXPIRED status when expiration mileage past but expiration date is in the future' do
      service.expiration_mileage = 5000
      service.expiration_date = Date.tomorrow

      service.status.should == Status::EXPIRED
    end

    it 'should calculate EXPIRED status when expiration date is in the past but expiration mileage is in the future' do
      service.expiration_mileage = 20000
      service.expiration_date = Date.yesterday

      service.status.should == Status::EXPIRED
    end

    it 'should calculate VALID status when expiration date is in the future and expiration mileage is in the future' do
      service.expiration_mileage = 20000
      service.expiration_date = Date.current + 61.days

      service.status.should == Status::VALID
    end

    it 'should calculate WARNING status when expiration mileage is within 500 miles' do
      service.expiration_date = Date.current + 61.days
      service.expiration_mileage = 10499

      service.status.should == Status::EXPIRING
    end

    it 'should calculate WARNING status when expiration date is within 60 days in the future' do
      service.expiration_date = Date.tomorrow
      service.expiration_mileage = 20000

      service.status.should == Status::EXPIRING
    end
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

        service.active_service_period = build(:service_period, start_date: 1.year.ago)

        service.should_not be_valid
        service.errors.full_messages_for(:last_service_date).first.should == 'Last service date must be after previous Last service date'
      end
    end
  end

  it_behaves_like 'an object that is sortable by status'

  describe '#update_expiration_date_and_mileage' do
    context 'expiration by mileage' do
      it 'should only update the expiration_mileage' do
        service_type = create(:service_type, interval_mileage: 5000, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE)
        service_period = create(:service_period, start_mileage: 0)
        service = create(:service, service_type: service_type, active_service_period: service_period)

        service.update_expiration_date_and_mileage

        service.expiration_date.should == nil
        service.expiration_mileage.should == 5000
      end
    end

    context 'expiration by date' do
      it 'should only update the expiration_date' do
        service_type = create(:service_type, interval_mileage: nil, interval_date: '1 month', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
        service_period = create(:service_period, start_date: Date.new(2010, 5, 10))
        service = create(:service, service_type: service_type, active_service_period: service_period)

        service.update_expiration_date_and_mileage

        service.expiration_date.should == Date.new(2010, 6, 10)
        service.expiration_mileage.should == nil
      end
    end

    context 'expiration by date and mileage' do
      it 'should update both expiration_date and expiration_mileage' do
        service_type = create(:service_type, interval_mileage: 5000, interval_date: '1 month', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE)
        service_period = create(:service_period, start_date: Date.new(2010, 5, 10), start_mileage: 0)
        service = create(:service, service_type: service_type, active_service_period: service_period)

        service.update_expiration_date_and_mileage

        service.expiration_date.should == Date.new(2010, 6, 10)
        service.expiration_mileage.should == 5000
      end
    end
  end

  describe '#calculate_mileage' do
    context 'when start_mileage is 1000' do
      let(:service_period) { build(:service_period, start_mileage: 10000) }
      let(:service) { build(:service, active_service_period: service_period) }

      it 'should return 13000 when interval_mileage is 3000' do
        service_type = build(:service_type, interval_mileage: 3000)
        service.service_type = service_type
        service.calculate_mileage.should == 13000
      end

      it 'should return 13000 when interval_mileage is 3000' do
        service_type = build(:service_type, interval_mileage: 15000)
        service.service_type = service_type
        service.calculate_mileage.should == 25000
      end

      it 'should return 13000 when interval_mileage is 3000' do
        service_type = build(:service_type, interval_mileage: 50000)
        service.service_type = service_type
        service.calculate_mileage.should == 60000
      end
    end

    it 'should return nil for nil start mileage' do
      service_period = build(:service_period, start_mileage: nil)
      service_type = build(:service_type, interval_mileage: 3000)
      service = build(:service, active_service_period: service_period, service_type: service_type)
      service.calculate_mileage.should be_nil
    end

    it 'should return if not mileage_based expiration_type' do
      service_period = build(:service_period, start_mileage: 0)
      service_type = build(:service_type, interval_mileage: 3000, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
      service = build(:service, active_service_period: service_period, service_type: service_type)
      service.calculate_mileage.should be_nil
    end

    describe '#reservice' do
      let(:service_type) { create(:service_type, interval_date: Interval::ONE_MONTH.text, interval_mileage: 5000) }
      let(:service) { create(:service, service_type: service_type) }
      let(:original_active_service_period) { create(:service_period, service: service) }
      let(:start_date) { Date.current }
      let(:start_mileage) { 10_000 }
      let(:comments) { 'some comments' }
      let(:attributes) { {start_date: start_date, start_mileage: start_mileage, comments: comments} }

      subject { service }

      before do
        service.active_service_period = original_active_service_period
        service.save
        service.reservice(attributes)
      end

      its(:active_service_period) { should_not == original_active_service_period }
      its(:last_service_date) { should == start_date }
      its(:last_service_mileage) { should == start_mileage }
      its(:comments) { should == comments }
      its(:expiration_date) { should == start_date + 1.month }
      its(:expiration_mileage) { should == 15_000 }
    end
  end
end