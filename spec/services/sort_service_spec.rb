require 'spec_helper'

describe SortService do
  context 'equipment' do
    it 'should sort ascending' do
      equipment =
        [
          new_equipment(name: 'zeta'),
          new_equipment(name: 'beta'),
          new_equipment(name: 'alpha')
        ]

      results = SortService.new.sort(equipment, 'name', 'asc').map(&:name)
      results.should == ['alpha', 'beta', 'zeta']
    end

    it 'should sort descending' do
      equipment =
        [
          new_equipment(name: 'zeta'),
          new_equipment(name: 'beta'),
          new_equipment(name: 'alpha')
        ]

      results = SortService.new.sort(equipment, 'name', 'desc').map(&:name)
      results.should == ['zeta', 'beta', 'alpha']
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