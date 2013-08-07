require 'spec_helper'

describe Equipment do
  before { @equipment = new_equipment }

  subject { @equipment }

  it { should belong_to(:customer) }
  it { should belong_to(:location) }
  it { should belong_to(:employee) }

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

  it 'should answer assigned_to_location?' do
    location = create_location
    location_assigned_equipment = create_equipment(location_id: location.id)
    employee = create_employee
    employee_assigned_equipment = create_equipment(employee_id: employee.id)

    location_assigned_equipment.should be_assigned_to_location
    employee_assigned_equipment.should_not be_assigned_to_location
  end

  it 'should answer assigned_to_employee?' do
    location = create_location
    location_assigned_equipment = create_equipment(location_id: location.id)
    employee = create_employee
    employee_assigned_equipment = create_equipment(employee_id: employee.id)

    employee_assigned_equipment.should be_assigned_to_employee
    location_assigned_equipment.should_not be_assigned_to_employee
  end

  it 'should respond to assigned_to' do
    location = create_location
    location_assigned_equipment = create_equipment(location_id: location.id)
    employee = create_employee
    employee_assigned_equipment = create_equipment(employee_id: employee.id)

    employee_assigned_equipment.assigned_to.should == employee
    location_assigned_equipment.assigned_to.should == location
  end

  it 'should respond to inspection_type' do
    inspectable_equipment = new_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text)
    non_inspectable_equipment = new_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text)

    inspectable_equipment.inspection_type.should == 'Inspectable'
    non_inspectable_equipment.inspection_type.should == 'Non-Inspectable'
  end
end
