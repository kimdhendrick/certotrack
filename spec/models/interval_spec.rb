require 'spec_helper'

describe Interval do
  it 'should display as strings' do
    Interval::ONE_MONTH.to_s.should == '1 month'
    Interval::THREE_MONTHS.to_s.should == '3 months'
    Interval::SIX_MONTHS.to_s.should == '6 months'
    Interval::ONE_YEAR.to_s.should == 'Annually'
    Interval::QUARTERLY_ONE_YEAR.to_s.should == 'Quarterly/Annually'
    Interval::TWO_YEARS.to_s.should == '2 years'
    Interval::THREE_YEARS.to_s.should == '3 years'
    Interval::FIVE_YEARS.to_s.should == '5 years'
    Interval::NOT_REQUIRED.to_s.should == 'Not Required'
  end

  describe '#lookup' do
    it 'should lookup by text' do
      Interval.lookup('1 month').should == Interval::ONE_MONTH.id
    end

    it 'should handle null' do
      Interval.lookup(nil).should be_nil
    end
  end
  describe '#from' do
    let(:start_date) { Date.new(2010, 1, 1) }

    it 'should calculate the interval from a given start date' do
      Interval::ONE_MONTH.from(start_date).should == Date.new(2010, 2, 1)
      Interval::THREE_MONTHS.from(start_date).should == Date.new(2010, 4, 1)
      Interval::SIX_MONTHS.from(start_date).should == Date.new(2010, 7, 1)
      Interval::ONE_YEAR.from(start_date).should == Date.new(2011, 1, 1)
      Interval::TWO_YEARS.from(start_date).should == Date.new(2012, 1, 1)
      Interval::THREE_YEARS.from(start_date).should == Date.new(2013, 1, 1)
      Interval::FIVE_YEARS.from(start_date).should == Date.new(2015, 1, 1)
      Interval::NOT_REQUIRED.from(start_date).should be_nil
    end

    context 'Quarterly Annual' do
      context 'when in the first quarter' do
        it 'should find the next quarter of the following year' do
          Interval::QUARTERLY_ONE_YEAR.from(Date.new(2010, 1, 1)).should == Date.new(2011, 4, 1)
          Interval::QUARTERLY_ONE_YEAR.from(Date.new(2010, 2, 15)).should == Date.new(2011, 4, 1)
          Interval::QUARTERLY_ONE_YEAR.from(Date.new(2010, 3, 31)).should == Date.new(2011, 4, 1)
        end
      end

      context 'when in the second quarter' do
        it 'should find the next quarter of the following year' do
          Interval::QUARTERLY_ONE_YEAR.from(Date.new(2010, 4, 15)).should == Date.new(2011, 7, 1)
        end
      end

      context 'when in the third quarter' do
        it 'should find the next quarter of the following year' do
          Interval::QUARTERLY_ONE_YEAR.from(Date.new(2010, 8, 15)).should == Date.new(2011, 10, 1)
        end
      end

      context 'when in the fourth quarter' do
        it 'should find the next quarter of the following year' do
          Interval::QUARTERLY_ONE_YEAR.from(Date.new(2010, 10, 15)).should == Date.new(2012, 1, 1)
        end
      end
    end

    it 'should be nil when nil start date' do
      Interval::ONE_MONTH.from(nil).should be_nil
    end
  end
end