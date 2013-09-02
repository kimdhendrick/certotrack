require 'spec_helper'

describe CertificationPeriod do
  it { should belong_to(:certification) }

  it 'should default units_achieved to 0' do
    CertificationPeriod.new.units_achieved.should == 0
  end

  it 'should validate presence of start_date' do
    certification_period = new_certification_period(start_date: nil)
    certification_period.should_not be_valid
    certification_period.errors[:last_certification_date].should == ["can't be blank"]
  end

  it 'should give invalid date if date is more than 100 years in the future' do
    certification_period = new_certification_period(start_date: Date.new(3000, 1, 1))
    certification_period.should_not be_valid
    certification_period.errors[:last_certification_date].should == ['is an invalid date']
  end

  it 'should give invalid date if date is more than 100 years in the past' do
    certification_period = new_certification_period(start_date: Date.new(1000, 1, 1))
    certification_period.should_not be_valid
    certification_period.errors[:last_certification_date].should == ['is an invalid date']
  end
end
