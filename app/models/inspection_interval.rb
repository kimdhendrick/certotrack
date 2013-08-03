class InspectionInterval < ActiveHash::Base

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

  ONE_MONTH = InspectionInterval.find(1)
  THREE_MONTHS = InspectionInterval.find(2)
  SIX_MONTHS = InspectionInterval.find(3)
  ONE_YEAR = InspectionInterval.find(4)
  TWO_YEARS = InspectionInterval.find(5)
  THREE_YEARS = InspectionInterval.find(6)
  FIVE_YEARS = InspectionInterval.find(7)
  NOT_REQUIRED = InspectionInterval.find(8)

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