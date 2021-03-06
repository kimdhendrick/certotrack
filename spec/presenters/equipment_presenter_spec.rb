require 'spec_helper'

describe EquipmentPresenter do
  it 'should respond to location name' do
    location = create(:location, name: 'Florida')
    location_assigned_equipment = create(:equipment, location: location)

    EquipmentPresenter.new(location_assigned_equipment, nil).assignee.should == 'Florida'
  end

  it 'should respond to employee name' do
    employee = create(:employee, first_name: 'John', last_name: 'Smith')
    employee_assigned_equipment = create(:equipment, employee: employee)

    EquipmentPresenter.new(employee_assigned_equipment, nil).assignee.should == 'Smith, John'
  end

  it 'should respond to Unassigned' do
    unassigned_equipment = create(:equipment, employee: nil, location: nil)

    EquipmentPresenter.new(unassigned_equipment, nil).assignee.should == 'Unassigned'
  end

  it 'should respond to assignee' do
    location = create(:location, name: 'Location Name')
    location_assigned_equipment = EquipmentPresenter.new(create(:equipment, location_id: location.id))
    employee = create(:employee, first_name: 'Joe', last_name: 'Schmoe')
    employee_assigned_equipment = EquipmentPresenter.new(create(:equipment, employee_id: employee.id))

    location_assigned_equipment.assignee.should == 'Location Name'
    employee_assigned_equipment.assignee.should == 'Schmoe, Joe'
  end

  it 'should respond to status_text' do
    equipment = EquipmentPresenter.new(create(:equipment))
    equipment.status_text.should == 'N/A'
  end

  it 'should respond to sort_key' do
    equipment = EquipmentPresenter.new(create(:equipment, name: 'Equipment Name'))
    equipment.sort_key.should == 'Equipment Name'
  end

  it 'should respond to inspection_interval_code' do
    equipment = EquipmentPresenter.new(create(:equipment, inspection_interval: Interval::THREE_MONTHS.text))
    equipment.inspection_interval_code.should == Interval::THREE_MONTHS.id
  end

  it 'should respond to last_inspection_date' do
    equipment = EquipmentPresenter.new(create(:equipment, last_inspection_date: Date.new(2013, 5, 12)))
    equipment.last_inspection_date.should == '05/12/2013'
  end

  it 'should respond to last_inspection_date_sort_key' do
    equipment = EquipmentPresenter.new(create(:equipment, last_inspection_date: Date.new(2013, 5, 12)))
    equipment.last_inspection_date_sort_key.should == Date.new(2013, 5, 12)
  end

  it 'should respond to expiration_date' do
    equipment = EquipmentPresenter.new(create(:equipment, expiration_date: Date.new(2012, 6, 20)))
    equipment.expiration_date.should == '06/20/2012'
  end

  it 'should respond to expiration' do
    equipment = EquipmentPresenter.new(create(:equipment, expiration_date: Date.new(2012, 6, 20)))
    equipment.expiration.should == Date.new(2012, 6, 20)
  end

  it 'should respond to created_at' do
    equipment = EquipmentPresenter.new(create(:equipment, created_at: Date.new(2010, 1, 1)))
    equipment.created_at.should == '01/01/2010'
  end

  it 'should respond to created_by' do
    equipment = EquipmentPresenter.new(create(:equipment, created_by: 'username'))
    equipment.created_by.should == 'username'
  end

  describe 'edit_link' do
    it 'should create a link to the edit page' do
      equipment = create(:equipment)
      subject = EquipmentPresenter.new(equipment, view)
      subject.edit_link.should =~ /<a.*>Edit<\/a>/
    end
  end

  describe 'delete_link' do
    it 'should create a link to the delete page' do
      equipment = build(:equipment)
      subject = EquipmentPresenter.new(equipment, view)
      subject.delete_link.should =~ /<a.*>Delete<\/a>/
    end
  end

  subject { EquipmentPresenter.new(create(:equipment)) }
  it_behaves_like 'an object that is sortable by status'
end