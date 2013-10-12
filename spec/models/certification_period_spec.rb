require 'spec_helper'

describe CertificationPeriod do
  subject { CertificationPeriod.new(start_date: Date.new(2013, 9, 6)) }

  it { should belong_to(:certification) }

  it 'should default units_achieved to 0' do
    subject.units_achieved.should == 0
  end

  it 'should not allow negative units_achieved' do
    subject.units_achieved = -1
    subject.should_not be_valid
    subject.errors[:units_achieved].should == ['must be greater than or equal to 0']
  end

  it 'should validate presence of start_date' do
    subject.start_date = nil
    subject.should_not be_valid
    subject.errors[:start_date].should == ['is not a valid date']
  end

  describe "new date validations" do
    subject { CertificationPeriod.new(start_date: Date.today) }

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
