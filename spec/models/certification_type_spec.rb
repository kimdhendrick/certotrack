require 'spec_helper'

describe CertificationType do
  before { @certification_type = new_certification_type }

  subject { @certification_type }

  it { should validate_presence_of :name }
  it { should belong_to(:customer) }

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
    new_certification_type(inspection_interval: InspectionInterval::ONE_MONTH.text).should be_valid
    new_certification_type(inspection_interval: InspectionInterval::THREE_MONTHS.text).should be_valid
    new_certification_type(inspection_interval: InspectionInterval::SIX_MONTHS.text).should be_valid
    new_certification_type(inspection_interval: InspectionInterval::ONE_YEAR.text).should be_valid
    new_certification_type(inspection_interval: InspectionInterval::TWO_YEARS.text).should be_valid
    new_certification_type(inspection_interval: InspectionInterval::FIVE_YEARS.text).should be_valid
    new_certification_type(inspection_interval: InspectionInterval::NOT_REQUIRED.text).should be_valid

    new_certification_type(inspection_interval: 'blah').should_not be_valid
  end

  it 'should respond to units_based?' do
    new_certification_type(units_required: 0).should_not be_units_based
    new_certification_type(units_required: 1).should be_units_based
  end
end