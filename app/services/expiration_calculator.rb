class ExpirationCalculator
  def calculate(start_date, interval)
    return if start_date.blank?

    case interval
      when Interval::ONE_MONTH
        return start_date + 1.month
      when Interval::THREE_MONTHS
        return start_date + 3.months
      when Interval::SIX_MONTHS
        return start_date + 6.months
      when Interval::ONE_YEAR
        return start_date + 1.year
      when Interval::TWO_YEARS
        return start_date + 2.years
      when Interval::THREE_YEARS
        return start_date + 3.years
      when Interval::FIVE_YEARS
        return start_date + 5.years
    end
  end
end