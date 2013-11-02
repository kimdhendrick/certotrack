require 'spec_helper'

describe Certification do
  it { should belong_to(:customer) }
  it { should belong_to(:certification_type) }
  it { should belong_to(:employee) }
  it { should belong_to(:active_certification_period) }
  it 'should validate the uniqueness of certification_type_id' do
    certification = create(:certification)
    certification.should validate_uniqueness_of(:certification_type_id).
             scoped_to(:employee_id).
             with_message(/already assigned to this Employee. Please update existing Certification/)

  end
  it { should validate_presence_of :active_certification_period }
  it { should validate_presence_of :certification_type }
  it { should validate_presence_of :employee }
  it { should validate_presence_of :customer }

  context 'non-units based certification type' do
    let (:certification_type) { create(:certification_type, units_required: 0) }
    let (:certification) { build(:certification, certification_type: certification_type) }
    let (:certification_period) { create(:certification_period, certification: certification) }

    it 'should calculate NA status when no expiration date' do
      certification.expiration_date = nil

      certification.status.should == Status::NA
    end

    it 'should calculate VALID status when expiration date is in the future' do
      certification.expiration_date = Date.today + 61.days

      certification.status.should == Status::VALID
    end

    it 'should calculate EXPIRED status when expiration date is in the past' do
      certification.expiration_date = Date.yesterday

      certification.status.should == Status::EXPIRED
    end

    it 'should calculate WARNING status when expiration date is within 60 days in the future' do
      certification.expiration_date = Date.tomorrow

      certification.status.should == Status::EXPIRING
    end

    it 'should answer expired? when expired' do
      certification.expiration_date = Date.yesterday

      certification.should be_expired
    end

    it 'should answer expired? when not expired' do
      certification.expiration_date = Date.tomorrow

      certification.should_not be_expired
    end

    it 'should answer expiring? when expiring' do
      certification.expiration_date = Date.tomorrow

      certification.should be_expiring
    end

    it 'should answer expiring? when not expiring' do
      certification.expiration_date = Date.today

      certification.should_not be_expiring
    end
  end

  context 'units based certification type' do
    let (:certification_type) { create(:certification_type, units_required: 100) }
    let (:certification) { build(:certification, certification_type: certification_type) }
    let (:certification_period) { create(:certification_period, certification: certification) }

    it 'should calculate VALID status when units achieved meets or exceeds units required' do
      certification.units_achieved = 101

      certification.status.should == Status::VALID
    end

    it 'should calculate recertify when expiration date is not set and units achieved less than required' do
      certification.units_achieved = 99
      certification.expiration_date = nil

      certification.status.should == Status::RECERTIFY
    end

    it 'should calculate recertify when expiration date is in the past and units achieved less than required' do
      certification.units_achieved = 99
      certification.expiration_date = Date.yesterday

      certification.status.should == Status::RECERTIFY
    end

    it 'should calculate pending when expiration date is not past and units achieved less than required' do
      certification.units_achieved = 99
      certification.expiration_date = Date.tomorrow

      certification.status.should == Status::PENDING
    end

    it 'should answer recertification_required? when recertification is required' do
      certification.units_achieved = 99
      certification.expiration_date = Date.yesterday

      certification.should be_recertification_required
    end

    it 'should answer recertification_required? when valid' do
      certification.units_achieved = 101

      certification.should_not be_recertification_required
    end
  end

  it 'should respond to status_code for sorting' do
    certification_type = create(:certification_type, units_required: 100)
    certification = build(:certification, certification_type: certification_type)

    certification.status_code.should == certification.status.sort_order
  end

  it 'should respond to active_certification_period' do
    certification = create(:certification)

    certification.active_certification_period.should be_a(CertificationPeriod)
  end

  it 'should respond to last_certification_date' do
    certification = create(:certification)
    certification.active_certification_period.start_date = Date.new(2010, 5, 10)

    certification.last_certification_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to last_certification_date=' do
    certification = create(:certification)
    certification.last_certification_date = Date.new(2010, 5, 10)

    certification.last_certification_date.should == Date.new(2010, 5, 10)
    certification.active_certification_period.start_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to expiration_date' do
    certification = create(:certification)
    certification.active_certification_period.end_date = Date.new(2012, 1, 2)

    certification.expiration_date.should == Date.new(2012, 1, 2)
  end

  it 'should respond to expiration_date=' do
    certification = create(:certification)
    certification.expiration_date = Date.new(2010, 5, 10)

    certification.expiration_date.should == Date.new(2010, 5, 10)
    certification.active_certification_period.end_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to trainer' do
    certification = create(:certification)
    certification.active_certification_period.trainer = 'Trainer Joe'

    certification.trainer.should == 'Trainer Joe'
  end

  it 'should respond to trainer=' do
    certification = create(:certification)
    certification.trainer = 'Hiya'

    certification.trainer.should == 'Hiya'
    certification.active_certification_period.trainer.should == 'Hiya'
  end

  it 'should respond to comments' do
    certification = create(:certification)
    certification.active_certification_period.comments= 'something special'

    certification.comments.should == 'something special'
  end

  it 'should respond to comments=' do
    certification = create(:certification)
    certification.comments = 'Hiya'

    certification.comments.should == 'Hiya'
    certification.active_certification_period.comments.should == 'Hiya'
  end

  it 'should respond to units_achieved' do
    certification = create(:certification)
    certification.active_certification_period.units_achieved = 10

    certification.units_achieved.should == 10
  end

  it 'should respond to units_achieved=' do
    certification = create(:certification)
    certification.units_achieved = 10

    certification.units_achieved.should == 10
    certification.active_certification_period.units_achieved.should == 10
  end

  it 'should respond to units_required' do
    certification_type = create(:certification_type, units_required: 100)
    certification = create(:certification, certification_type: certification_type, customer: create(:customer))
    certification.units_required.should == 100
  end

  it 'should respond to name' do
    certification_type = create(:certification_type, name: 'Scrum Master')
    certification = create(:certification, certification_type: certification_type, customer: create(:customer))
    certification.name.should == 'Scrum Master'
  end

  it 'should respond to interval' do
    certification_type = create(:certification_type, interval: Interval::THREE_MONTHS.text)
    certification = create(:certification, certification_type: certification_type, customer: create(:customer))
    certification.interval.should == '3 months'
  end

  it 'should respond to units_based?' do
    build(:certification).should_not be_units_based
    build(:units_based_certification).should be_units_based
  end

  it 'should default active to true' do
    certification = Certification.new
    certification.active.should be_true
  end


  describe "new date validations" do
    subject { Certification.new }
    let(:certification_period) { CertificationPeriod.new(start_date: start_date) }

    before do
      subject.active_certification_period = certification_period
      subject.valid?
    end

    before { Timecop.freeze(2013, 9, 6) }
    after { Timecop.return }

    context 'when start_date is invalid' do
      let(:start_date) { '1111111' }

      it 'should have the correct message' do
        subject.errors.full_messages_for(:"active_certification_period.start_date").first.should == 'Last certification date is not a valid date'
      end
    end

    context 'when start_date is more than 100 years in the future' do
      let(:start_date) { 101.years.from_now }

      it 'should have the correct message' do
        subject.errors.full_messages_for(:"active_certification_period.start_date").first.should == 'Last certification date out of range'
      end
    end

    context 'when start_date is more than 100 years in the past' do
      let(:start_date) { 101.years.ago }

      it 'should have the correct message' do
        subject.errors.full_messages_for(:"active_certification_period.start_date").first.should == 'Last certification date out of range'
      end
    end
  end

  it_behaves_like 'an object that is sortable by status'

  describe '#recertify' do
    subject { create(:certification) }
    let(:start_date) { 2.days.from_now }
    let(:trainer) { 'New Trainer' }
    let(:comments) { 'New Comments' }
    let(:units_achieved) { 42 }
    let(:attributes) { {start_date: start_date, trainer: trainer, comments: comments, units_achieved: units_achieved}}

    before do
      @original_certification_period = subject.active_certification_period
      Timecop.freeze(Time.local(2013, 10, 20, 18, 16, 00))
    end

    after { Timecop.return }

    it 'should keep the original certification period in its history' do
      subject.recertify(attributes)
      subject.certification_periods.should include(@original_certification_period)
    end

    it 'should create a new active_certification_period' do
      subject.recertify(attributes)
      subject.active_certification_period.should_not  == @original_certification_period
    end

    it 'should set new trainer in active_certification_period' do
      subject.recertify(trainer: trainer)
      subject.active_certification_period.trainer.should == trainer
    end

    it 'should set new start_date in active_certification_period' do
      subject.recertify(start_date: start_date)
      subject.last_certification_date.should == start_date
    end

    it 'should set new comments in active_certification_period' do
      subject.recertify(comments: comments)
      subject.active_certification_period.comments.should == comments
    end

    it 'should set new units_achieved in active_certification_period' do
      subject.recertify(units_achieved: units_achieved)
      subject.active_certification_period.units_achieved.should == units_achieved
    end

    it 'should create a valid active_certification_period' do
      subject.recertify(attributes)
      subject.active_certification_period.should be_valid
    end

    it 'should recalculate expiration_date' do
      subject.recertify(attributes)
      subject.expiration_date.should == Time.utc(2014, 10, 23, 0, 16, 0)
    end
  end
end