require 'spec_helper'

describe Equipment do
  before { @equipment = build(:equipment) }

  subject { @equipment }

  it { should validate_presence_of :name }
  it { should validate_presence_of :serial_number }
  it { should belong_to(:customer) }
  it { should belong_to(:location) }
  it { should belong_to(:employee) }
  it { should validate_uniqueness_of(:serial_number).scoped_to(:customer_id) }

  it 'should require last_inspection_date if Inspectable' do
    equipment = build(:equipment, inspection_interval: Interval::ONE_YEAR.text, last_inspection_date: nil)
    equipment.should_not be_valid
    equipment.errors[:last_inspection_date].should == ["is not a valid date"]
  end

  it 'should not require last_inspection_date if Non-Inspectable' do
    equipment = build(:equipment, inspection_interval: Interval::NOT_REQUIRED.text, last_inspection_date: nil)
    equipment.should be_valid
  end

  it 'should give invalid date if date is more than 100 years in the future' do
    equipment = build(:equipment, last_inspection_date: Date.new(3000,1,1))
    equipment.should_not be_valid
    equipment.errors[:last_inspection_date].should == ['out of range']
  end

  it 'should give invalid date if date is more than 100 years in the past' do
    equipment = build(:equipment, last_inspection_date: Date.new(1000,1,1))
    equipment.should_not be_valid
    equipment.errors[:last_inspection_date].should == ['out of range']
  end

  it 'should be able to assign a customer to equipment' do
    customer = new_customer
    equipment = build(:equipment)
    equipment.customer = customer

    equipment.customer.should == customer
  end

  it 'should calculate NA status when no expiration date' do
    equipment = build(:equipment, expiration_date: nil)

    equipment.status.should == Status::NA
  end

  it 'should calculate VALID status when expiration date is in the future' do
    equipment = build(:equipment, expiration_date: Date.today + 61.days)

    equipment.status.should == Status::VALID
  end

  it 'should calculate EXPIRED status when expiration date is in the past' do
    equipment = build(:equipment, expiration_date: Date.yesterday)

    equipment.status.should == Status::EXPIRED
  end

  it 'should calculate WARNING status when expiration date is within 60 days in the future' do
    equipment = build(:equipment, expiration_date: Date.tomorrow)

    equipment.status.should == Status::EXPIRING
  end

  it 'should answer expired?' do
    valid_equipment = build(:valid_equipment)
    expiring_equipment = build(:expiring_equipment)
    expired_equipment = build(:expired_equipment)
    non_inspectable_equipment = build(:equipment, expiration_date: nil, inspection_interval:Interval::NOT_REQUIRED)

    valid_equipment.expired?.should be_false
    expiring_equipment.expired?.should be_false
    expired_equipment.expired?.should be_true
    non_inspectable_equipment.expired?.should be_false
  end

  it 'should answer expiring?' do
    valid_equipment = build(:valid_equipment)
    expiring_equipment = build(:expiring_equipment)
    expired_equipment = build(:expired_equipment)
    non_inspectable_equipment = build(:equipment, expiration_date: nil, inspection_interval:Interval::NOT_REQUIRED)

    valid_equipment.expiring?.should be_false
    expired_equipment.expiring?.should be_false
    expiring_equipment.expiring?.should be_true
    non_inspectable_equipment.expired?.should be_false
  end

  it 'should validate inspection interval' do
    build(:equipment, inspection_interval: Interval::ONE_MONTH.text).should be_valid
    build(:equipment, inspection_interval: Interval::THREE_MONTHS.text).should be_valid
    build(:equipment, inspection_interval: Interval::SIX_MONTHS.text).should be_valid
    build(:equipment, inspection_interval: Interval::ONE_YEAR.text).should be_valid
    build(:equipment, inspection_interval: Interval::TWO_YEARS.text).should be_valid
    build(:equipment, inspection_interval: Interval::FIVE_YEARS.text).should be_valid
    build(:equipment, inspection_interval: Interval::NOT_REQUIRED.text).should be_valid

    build(:equipment, inspection_interval: 'blah').should_not be_valid
  end

  it 'should answer assigned_to_location?' do
    location = create_location
    location_assigned_equipment = create(:equipment, location_id: location.id)
    employee = create_employee
    employee_assigned_equipment = create(:equipment, employee_id: employee.id)

    location_assigned_equipment.should be_assigned_to_location
    employee_assigned_equipment.should_not be_assigned_to_location
  end

  it 'should answer assigned_to_employee?' do
    location = create_location
    location_assigned_equipment = create(:equipment, location_id: location.id)
    employee = create_employee
    employee_assigned_equipment = create(:equipment, employee_id: employee.id)

    employee_assigned_equipment.should be_assigned_to_employee
    location_assigned_equipment.should_not be_assigned_to_employee
  end

  it 'should respond to assigned_to' do
    location = create_location
    location_assigned_equipment = create(:equipment, location_id: location.id)
    employee = create_employee
    employee_assigned_equipment = create(:equipment, employee_id: employee.id)

    employee_assigned_equipment.assigned_to.should == employee
    location_assigned_equipment.assigned_to.should == location
  end

  it 'should respond to inspection_type' do
    inspectable_equipment = build(:equipment, inspection_interval: Interval::FIVE_YEARS.text)
    non_inspectable_equipment = build(:equipment, inspection_interval: Interval::NOT_REQUIRED.text)

    inspectable_equipment.inspection_type.should == 'Inspectable'
    non_inspectable_equipment.inspection_type.should == 'Non-Inspectable'
  end

  it 'should respond to inspection_interval_code' do
    one_month_equipment = build(:equipment, inspection_interval: Interval::ONE_MONTH.text)
    not_required_equipment = build(:equipment, inspection_interval: Interval::NOT_REQUIRED.text)

    one_month_equipment.inspection_interval_code.should == Interval::ONE_MONTH.id
    not_required_equipment.inspection_interval_code.should == Interval::NOT_REQUIRED.id
  end

  it 'should respond to status_code' do
    build(:valid_equipment).status_code.should == Status::VALID.id
    build(:expiring_equipment).status_code.should == Status::EXPIRING.id
    build(:expired_equipment).status_code.should == Status::EXPIRED.id
  end

  it 'should respond to assignee' do
    location = create_location(name: 'Location Name')
    location_assigned_equipment = create(:equipment, location_id: location.id)
    employee = create_employee(first_name: 'Joe', last_name: 'Schmoe')
    employee_assigned_equipment = create(:equipment, employee_id: employee.id)

    location_assigned_equipment.assignee.should == 'Location Name'
    employee_assigned_equipment.assignee.should == 'Schmoe, Joe'
  end
end
