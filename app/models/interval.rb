class Interval < ActiveHash::Base

  self.data = [
    {id: 1, text: '1 month', duration: 1.month},
    {id: 2, text: '3 months', duration: 3.months},
    {id: 3, text: '6 months', duration: 6.months},
    {id: 4, text: 'Annually', duration: 1.year},
    {id: 5, text: '2 years', duration: 2.years},
    {id: 6, text: '3 years', duration: 3.years},
    {id: 7, text: '5 years', duration: 5.years},
    {id: 8, text: 'Not Required', duration: nil}
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
    Interval.find_by_text(interval_text).try(&:id)
  end

  def from(start_date)
    return if start_date.blank?
    return if duration.nil?

    start_date + duration
  end
end