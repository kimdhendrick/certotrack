require 'spec_helper'

describe CertificationType do
  before { @certification_type = new_certification_type }

  subject { @certification_type }

  it { should validate_presence_of :name }
  it { should belong_to(:customer) }
  it { should validate_uniqueness_of(:name).scoped_to(:customer_id) }

  it 'should default units_required to 0' do
    certification_type = CertificationType.new
    certification_type.units_required.should == 0
  end

  it 'should not allow negative numbers for units_required' do
    new_certification_type(units_required: -1).should_not be_valid
    new_certification_type(units_required: 0).should be_valid
    new_certification_type(units_required: 1).should be_valid
  end

  it 'should only accept valid intervals' do
    new_certification_type(interval: Interval::ONE_MONTH.text).should be_valid
    new_certification_type(interval: Interval::THREE_MONTHS.text).should be_valid
    new_certification_type(interval: Interval::SIX_MONTHS.text).should be_valid
    new_certification_type(interval: Interval::ONE_YEAR.text).should be_valid
    new_certification_type(interval: Interval::TWO_YEARS.text).should be_valid
    new_certification_type(interval: Interval::FIVE_YEARS.text).should be_valid
    new_certification_type(interval: Interval::NOT_REQUIRED.text).should be_valid

    new_certification_type(interval: 'blah').should_not be_valid
  end

  it 'should respond to units_based?' do
    new_certification_type(units_required: 0).should_not be_units_based
    new_certification_type(units_required: 1).should be_units_based
  end

  it 'should respond to interval_code' do
    one_month_certification_type = new_certification_type(interval: Interval::ONE_MONTH.text)
    not_required_certification_type = new_certification_type(interval: Interval::NOT_REQUIRED.text)

    one_month_certification_type.interval_code.should == Interval::ONE_MONTH.id
    not_required_certification_type.interval_code.should == Interval::NOT_REQUIRED.id
  end

  it 'should display as a string' do
    certification_type = new_certification_type(name: 'certification name', interval: Interval::ONE_YEAR.text)
    certification_type.to_s.should == 'certification name:Annually'
  end
end