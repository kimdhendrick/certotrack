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

      SortService.new.sort(equipment, 'name', 'asc').map(&:name).should == ['alpha', 'beta', 'zeta']
    end

    it 'should sort descending' do
      equipment =
        [
          new_equipment(name: 'zeta'),
          new_equipment(name: 'beta'),
          new_equipment(name: 'alpha')
        ]

      SortService.new.sort(equipment, 'name', 'desc').map(&:name).should == ['zeta', 'beta', 'alpha']
    end
  end
end