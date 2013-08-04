require 'spec_helper'

describe Equipment do
  before { @equipment = new_equipment }

  subject { @equipment }

  it { should belong_to(:customer) }
  it { should belong_to(:location) }

  it 'should be able to assign a customer to equipment' do
    customer = new_customer
    equipment = new_equipment
    equipment.customer = customer

    equipment.customer.should == customer
  end

  it 'should calculate NA status when no expiration date' do
    equipment = new_equipment(expiration_date: nil)

    equipment.status.should == Status::NA
  end

  it 'should calculate VALID status when expiration date is in the future' do
    equipment = new_equipment(expiration_date: Date.today + 61.days)

    equipment.status.should == Status::VALID
  end

  it 'should calculate EXPIRED status when expiration date is in the past' do
    equipment = new_equipment(expiration_date: Date.yesterday)

    equipment.status.should == Status::EXPIRED
  end

  it 'should calculate WARNING status when expiration date is within 60 days in the future' do
    equipment = new_equipment(expiration_date: Date.tomorrow)

    equipment.status.should == Status::EXPIRING
  end

  it 'should answer expired?' do
    valid_equipment = new_valid_equipment
    expiring_equipment = new_expiring_equipment
    expired_equipment = new_expired_equipment

    valid_equipment.expired?.should be_false
    expiring_equipment.expired?.should be_false
    expired_equipment.expired?.should be_true
  end

  it 'should answer expiring?' do
    valid_equipment = new_valid_equipment
    expiring_equipment = new_expiring_equipment
    expired_equipment = new_expired_equipment

    valid_equipment.expiring?.should be_false
    expired_equipment.expiring?.should be_false
    expiring_equipment.expiring?.should be_true
  end

  it 'should validate inspection type' do
    new_equipment(inspection_type: InspectionType::INSPECTABLE.text).should be_valid
    new_equipment(inspection_type: InspectionType::NON_INSPECTABLE.text).should be_valid

    new_equipment(inspection_type: 'foo').should_not be_valid
  end

  it 'should validate inspection interval' do
    new_equipment(inspection_interval: InspectionInterval::ONE_MONTH.text).should be_valid
    new_equipment(inspection_interval: InspectionInterval::THREE_MONTHS.text).should be_valid
    new_equipment(inspection_interval: InspectionInterval::SIX_MONTHS.text).should be_valid
    new_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text).should be_valid
    new_equipment(inspection_interval: InspectionInterval::TWO_YEARS.text).should be_valid
    new_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text).should be_valid
    new_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text).should be_valid

    new_equipment(inspection_interval: 'blah').should_not be_valid
  end
end
