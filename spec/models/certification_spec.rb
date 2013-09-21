require 'spec_helper'

describe Certification do
  it { should belong_to(:customer) }
  it { should belong_to(:certification_type) }
  it { should belong_to(:employee) }
  it { should have_one(:active_certification_period) }
  it do
    should validate_uniqueness_of(:certification_type_id).
             scoped_to(:employee_id).
             with_message(/already assigned to this Employee. Please update existing Certification/)

  end
  it { should validate_presence_of :active_certification_period }
  it { should validate_presence_of :certification_type }
  it { should validate_presence_of :customer }

  context 'non-units based certification type' do
    before do
      @certification_type = create(:certification_type, units_required: 0)
      @certification = build(:certification, certification_type: @certification_type)
      @certification_period = create(:certification_period, certification: @certification)
    end

    it 'should calculate NA status when no expiration date' do
      @certification.expiration_date = nil

      @certification.status.should == Status::NA
    end

    it 'should calculate VALID status when expiration date is in the future' do
      @certification.expiration_date = Date.today + 61.days

      @certification.status.should == Status::VALID
    end

    it 'should calculate EXPIRED status when expiration date is in the past' do
      @certification.expiration_date = Date.yesterday

      @certification.status.should == Status::EXPIRED
    end

    it 'should calculate WARNING status when expiration date is within 60 days in the future' do
      @certification.expiration_date = Date.tomorrow

      @certification.status.should == Status::EXPIRING
    end
  end

  context 'units based certification type' do
    before do
      @certification_type = create(:certification_type, units_required: 100)
      @certification = build(:certification, certification_type: @certification_type)
      @certification_period = create(:certification_period, certification: @certification)
    end

    it 'should calculate VALID status when units achieved meets or exceeds units required' do
      @certification.units_achieved = 101

      @certification.status.should == Status::VALID
    end

    it 'should calculate recertify when expiration date is not set and units achieved less than required' do
      @certification.units_achieved = 99
      @certification.expiration_date = nil

      @certification.status.should == Status::RECERTIFY
    end

    it 'should calculate recertify when expiration date is in the past and units achieved less than required' do
      @certification.units_achieved = 99
      @certification.expiration_date = Date.yesterday

      @certification.status.should == Status::RECERTIFY
    end

    it 'should calculate pending when expiration date is not past and units achieved less than required' do
      @certification.units_achieved = 99
      @certification.expiration_date = Date.tomorrow

      @certification.status.should == Status::PENDING
    end
  end

  it 'should respond to its sort_key' do
    certification_type = create(:certification_type, units_required: 100)
    certification = build(:certification, certification_type: certification_type)

    certification.sort_key.should == certification.name
  end

  it 'should respond to status_code for sorting' do
    certification_type = create(:certification_type, units_required: 100)
    certification = build(:certification, certification_type: certification_type)

    certification.status_code.should == certification.status.sort_order
  end

  it 'should respond to active_certification_period' do
    certification = create(:certification, customer: create(:customer))

    certification.active_certification_period.should be_a(CertificationPeriod)
  end

  it 'should respond to last_certification_date' do
    certification = create(:certification, customer: create(:customer))
    certification.active_certification_period.start_date = Date.new(2010, 5, 10)

    certification.last_certification_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to last_certification_date=' do
    certification = create(:certification, customer: create(:customer))
    certification.last_certification_date = Date.new(2010, 5, 10)

    certification.last_certification_date.should == Date.new(2010, 5, 10)
    certification.active_certification_period.start_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to expiration_date' do
    certification = create(:certification, customer: create(:customer))
    certification.active_certification_period.end_date = Date.new(2012, 1, 2)

    certification.expiration_date.should == Date.new(2012, 1, 2)
  end

  it 'should respond to expiration_date=' do
    certification = create(:certification, customer: create(:customer))
    certification.expiration_date = Date.new(2010, 5, 10)

    certification.expiration_date.should == Date.new(2010, 5, 10)
    certification.active_certification_period.end_date.should == Date.new(2010, 5, 10)
  end

  it 'should respond to trainer' do
    certification = create(:certification, customer: create(:customer))
    certification.active_certification_period.trainer = 'Trainer Joe'

    certification.trainer.should == 'Trainer Joe'
  end

  it 'should respond to trainer=' do
    certification = create(:certification, customer: create(:customer))
    certification.trainer = 'Hiya'

    certification.trainer.should == 'Hiya'
    certification.active_certification_period.trainer.should == 'Hiya'
  end

  it 'should respond to comments' do
    certification = create(:certification, customer: create(:customer))
    certification.active_certification_period.comments= 'something special'

    certification.comments.should == 'something special'
  end

  it 'should respond to comments=' do
    certification = create(:certification, customer: create(:customer))
    certification.comments = 'Hiya'

    certification.comments.should == 'Hiya'
    certification.active_certification_period.comments.should == 'Hiya'
  end

  it 'should respond to units_achieved' do
    certification = create(:certification, customer: create(:customer))
    certification.active_certification_period.units_achieved = 10

    certification.units_achieved.should == 10
  end

  it 'should respond to units_achieved=' do
    certification = create(:certification, customer: create(:customer))
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

  it 'should respond to units_based?' do
    build(:certification).should_not be_units_based
    build(:units_based_certification).should be_units_based
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
end