class Interval < ActiveHash::Base

  self.data = [
    {id: 1, text: '1 month'},
    {id: 2, text: '3 months'},
    {id: 3, text: '6 months'},
    {id: 4, text: 'Annually'},
    {id: 5, text: '2 years'},
    {id: 6, text: '3 years'},
    {id: 7, text: '5 years'},
    {id: 8, text: 'Not Required'}
  ]

  alias :to_s :text

  ONE_MONTH = Interval.find(1)
  THREE_MONTHS = Interval.find(2)
  SIX_MONTHS = Interval.find(3)
  ONE_YEAR = Interval.find(4)
  TWO_YEARS = Interval.find(5)
  THREE_YEARS = Interval.find(6)
  FIVE_YEARS = Interval.find(7)
  NOT_REQUIRED = Interval.find(8)

  def self.lookup(interval_text)
    Interval.find_by_text(interval_text).id
  end

  def expires_on(start_date)
    return if start_date.blank?

    case id
      when 1
        return start_date + 1.month
      when 2
        return start_date + 3.months
      when 3
        return start_date + 6.months
      when 4
        return start_date + 1.year
      when 5
        return start_date + 2.years
      when 6
        return start_date + 3.years
      when 7
        return start_date + 5.years
    end
  end
end