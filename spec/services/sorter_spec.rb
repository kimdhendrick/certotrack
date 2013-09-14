require 'spec_helper'

describe Sorter do
  context 'equipment' do

    it 'should sort strings ascending' do
      equipment =
        [
          build(:equipment, name: 'zeta'),
          build(:equipment, name: nil),
          build(:equipment, name: 'alpha'),
          build(:equipment, name: 'beta')
        ]

      results = Sorter.new.sort(equipment, 'name', 'asc').map(&:name)
      results.should == ['alpha', 'beta', 'zeta', nil]
    end

    it 'should sort strings descending' do
      equipment =
        [
          build(:equipment, name: 'zeta'),
          build(:equipment, name: 'beta'),
          build(:equipment, name: nil),
          build(:equipment, name: 'alpha')
        ]

      results = Sorter.new.sort(equipment, 'name', 'desc').map(&:name)
      results.should == [nil, 'zeta', 'beta', 'alpha']
    end

    it 'should sort dates ascending' do
      today = Date.today
      equipment =
        [
          build(:equipment, expiration_date: today),
          build(:equipment, expiration_date: nil)
        ]

      results = Sorter.new.sort(equipment, 'expiration_date', 'asc').map(&:expiration_date)
      results.should == [today, nil]
    end

    it 'should sort dates descending' do
      today = Date.today

      equipment =
        [
          build(:equipment, expiration_date: today),
          build(:equipment, expiration_date: nil)
        ]

      results = Sorter.new.sort(equipment, 'expiration_date', 'desc').map(&:expiration_date)
      results.should == [nil, today]
    end

    it 'should default to name if no field provided' do
      equipment =
        [
          build(:equipment, name: 'zeta'),
          build(:equipment, name: 'beta'),
          build(:equipment, name: 'alpha')
        ]

      results = Sorter.new.sort(equipment, nil).map(&:name)
      results.should == ['alpha', 'beta', 'zeta']
    end

    it 'should default to ascending if no direction provided' do
      equipment =
        [
          build(:equipment, name: 'zeta'),
          build(:equipment, name: 'beta'),
          build(:equipment, name: 'alpha')
        ]

      results = Sorter.new.sort(equipment, 'name').map(&:name)
      results.should == ['alpha', 'beta', 'zeta']
    end

    it 'should default to ascending if no direction provided' do
      equipment =
        [
          build(:equipment, name: 'zeta'),
          build(:equipment, name: 'beta'),
          build(:equipment, name: 'alpha')
        ]

      results = Sorter.new.sort(equipment, 'name').map(&:name)
      results.should == ['alpha', 'beta', 'zeta']
    end

    it 'should handle empty collections' do
      results = Sorter.new.sort([], 'name', 'asc')
      results.should == []
    end
  end
end