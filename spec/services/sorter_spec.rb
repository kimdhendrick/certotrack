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

    it 'should sort strings ignoring case' do
      equipment =
        [
          build(:equipment, name: 'ZEBRA'),
          build(:equipment, name: 'zeta'),
          build(:equipment, name: 'alpha'),
          build(:equipment, name: 'ACRoBAt')
        ]

      results = Sorter.new.sort(equipment, 'name', 'asc').map(&:name)
      results.should == ['ACRoBAt', 'alpha', 'ZEBRA', 'zeta']
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
      yesterday = Date.parse('2013-12-31')
      today = Date.parse('2014-01-01')
      tomorrow = Date.parse('2014-01-02')
      equipment =
        [
          build(:equipment, expiration_date: today),
          build(:equipment, expiration_date: yesterday),
          build(:equipment, expiration_date: tomorrow),
          build(:equipment, expiration_date: nil)
        ]

      results = Sorter.new.sort(equipment, 'expiration_date', 'asc').map(&:expiration_date)
      results.should == [yesterday, today, tomorrow, nil]
    end

    it 'should sort dates descending' do
      yesterday = Date.parse('2013-12-31')
      today = Date.parse('2014-01-01')
      tomorrow = Date.parse('2014-01-02')
      equipment =
        [
          build(:equipment, expiration_date: today),
          build(:equipment, expiration_date: yesterday),
          build(:equipment, expiration_date: tomorrow),
          build(:equipment, expiration_date: nil)
        ]

      results = Sorter.new.sort(equipment, 'expiration_date', 'desc').map(&:expiration_date)
      results.should == [nil, tomorrow, today, yesterday]
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

  context 'certification' do
    it 'should sort status asc' do
      certifications =
        [
          expiring = build(:certification, expiration_date: Date.tomorrow),
          expired = build(:certification, expiration_date: Date.yesterday),
          na = build(:certification, expiration_date: nil),
          valid = build(:certification, expiration_date: Date.current + 6.months)
        ]

      results = Sorter.new.sort(certifications, 'status', 'asc')
      results.should == [valid, expiring, expired, na]
    end
  end
end