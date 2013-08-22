require 'spec_helper'
describe EquipmentSearchService do

  describe 'search' do
    it 'should search by name' do
      match = create_equipment(name: 'Meter123')
      no_match = create_equipment(name: 'Box')

      EquipmentSearchService.new.search(Equipment.all, {name: 'Meter123'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {name: 'METER123'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {name: 'meter123'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {name: 'Meter'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {name: 'eter123'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {name: 'ter12'}).should == [match]
    end

    it 'should search by serial_number' do
      match = create_equipment(serial_number: 'ABC123')
      no_match = create_equipment(serial_number: 'XYZ')

      EquipmentSearchService.new.search(Equipment.all, {serial_number: 'ABC123'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {serial_number: 'abc123'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {serial_number: 'aBc123'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {serial_number: 'ABC'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {serial_number: '123'}).should == [match]
      EquipmentSearchService.new.search(Equipment.all, {serial_number: 'BC12'}).should == [match]
    end

    it 'should search by employee_id' do
      match = create_equipment(employee_id: 1)
      no_match = create_equipment(employee_id: 2)

      EquipmentSearchService.new.search(Equipment.all, {employee_id: 1}).should == [match]
    end

    it 'should search by location_id' do
      match = create_equipment(location_id: 1)
      no_match = create_equipment(location_id: 2)

      EquipmentSearchService.new.search(Equipment.all, {location_id: 1}).should == [match]
    end

    it 'should search by all fields' do
      employee_match = create_equipment(employee_id: 7)
      location_match = create_equipment(location_id: 3)
      name_match = create_equipment(name: 'Meter123')
      serial_number_match = create_equipment(serial_number: 'ABC123')
      no_match = create_equipment(name: 'blah', serial_number: 'blah', employee_id: nil, location_id: nil)

      search_params =
        {
          name: 'Meter123',
          serial_number: 'ABC123',
          employee_id: 7,
          location_id: 3
        }

      EquipmentSearchService.new.search(Equipment.all, search_params).should =~
        [
          employee_match,
          location_match,
          name_match,
          serial_number_match
        ]
    end

    it 'should search by name OR serial_number' do
      match = create_equipment(name: 'Meter', serial_number: 'ABC123')
      EquipmentSearchService.new.search(Equipment.all, {name: 'Meter', serial_number: 'ABC123'}).should == [match]
    end
  end
end