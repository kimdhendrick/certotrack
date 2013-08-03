require 'spec_helper'

describe Equipment do
  before { @equipment = new_equipment }

  subject { @equipment }

  it { should belong_to(:customer) }

  it 'should provide its accessible parameters' do
    Equipment.accessible_parameters.should == [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :inspection_type,
      :notes
    ]
  end

  it 'should be able to assign a customer to equipment' do
    customer = new_valid_customer
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

  it 'should be inspectable or not' do
    new_equipment(inspection_type: 'Inspectable').should be_valid
    new_equipment(inspection_type: 'Non-Inspectable').should be_valid
    new_equipment(inspection_type: 'foo').should_not be_valid
  end
end
