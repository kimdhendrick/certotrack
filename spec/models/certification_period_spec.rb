require 'spec_helper'

describe CertificationPeriod do
  it { should belong_to(:certification) }

  it 'should default units_achieved to 0' do
    subject.units_achieved.should == 0
  end

  it 'should validate presence of start_date' do
    subject.start_date = nil
    subject.should_not be_valid
    subject.errors[:start_date].should == ['is not a valid date']
  end

  it 'should give invalid date if date is more than 100 years in the future' do
    subject.start_date = Date.new(3000, 1, 1)
    subject.should_not be_valid
    subject.errors[:start_date].should == ['out of range']
  end

  it 'should give invalid date if date is more than 100 years in the past' do
    subject.start_date = Date.new(1000, 1, 1)
    subject.should_not be_valid
    subject.errors[:start_date].should == ['out of range']
  end
end
