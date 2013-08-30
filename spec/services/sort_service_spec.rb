require 'spec_helper'

describe SortService do
  context 'equipment' do

    it 'should sort strings ascending' do
      equipment =
        [
          new_equipment(name: 'zeta'),
          new_equipment(name: nil),
          new_equipment(name: 'alpha'),
          new_equipment(name: 'beta')
        ]

      results = SortService.new.sort(equipment, 'name', 'asc').map(&:name)
      results.should == ['alpha', 'beta', 'zeta', nil]
    end

    it 'should sort strings descending' do
      equipment =
        [
          new_equipment(name: 'zeta'),
          new_equipment(name: 'beta'),
          new_equipment(name: nil),
          new_equipment(name: 'alpha')
        ]

      results = SortService.new.sort(equipment, 'name', 'desc').map(&:name)
      results.should == [nil, 'zeta', 'beta', 'alpha']
    end

    it 'should sort dates ascending' do
      today = Date.today
      equipment =
        [
          new_equipment(expiration_date: today),
          new_equipment(expiration_date: nil)
        ]

      results = SortService.new.sort(equipment, 'expiration_date', 'asc').map(&:expiration_date)
      results.should == [today, nil]
    end

    it 'should sort dates descending' do
      today = Date.today

      equipment =
        [
          new_equipment(expiration_date: today),
          new_equipment(expiration_date: nil)
        ]

      results = SortService.new.sort(equipment, 'expiration_date', 'desc').map(&:expiration_date)
      results.should == [nil, today]
    end

    it 'should default to name if bad column given' do
      equipment =
        [
          new_equipment(name: 'zeta'),
          new_equipment(name: 'beta'),
          new_equipment(name: 'alpha')
        ]

      results = SortService.new.sort(equipment, 'bad_column_name', 'asc').map(&:name)
      results.should == ['alpha', 'beta', 'zeta']
    end

    it 'should default to specified column if provided' do
      equipment =
        [
          new_equipment(serial_number: 'zeta', name: 'a'),
          new_equipment(serial_number: 'beta', name: 'b'),
          new_equipment(serial_number: 'alpha', name: 'c')
        ]

      results = SortService.new.sort(equipment, 'bad_column_name', 'asc', 'serial_number').map(&:serial_number)
      results.should == ['alpha', 'beta', 'zeta']
    end

    it 'should default to ascending if bad direction given' do
      equipment =
        [
          new_equipment(name: 'zeta'),
          new_equipment(name: 'beta'),
          new_equipment(name: 'alpha')
        ]

      results = SortService.new.sort(equipment, 'name', 'bad_sort_direction').map(&:name)
      results.should == ['alpha', 'beta', 'zeta']
    end

    it 'should handle empty collections' do
      results = SortService.new.sort([], 'name', 'asc')
      results.should == []
    end
  end
end