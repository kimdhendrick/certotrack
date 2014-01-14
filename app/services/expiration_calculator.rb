class ExpirationCalculator
  #def calculate(start_date, interval)
  #  return if start_date.blank?
  #
  #  interval.from(start_date)
  #end

  def calculate_mileage(start_mileage, interval)
    return if start_mileage.blank? || interval.blank?

    start_mileage + interval
  end
end