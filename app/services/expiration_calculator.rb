class ExpirationCalculator

  def calculate_mileage(start_mileage, interval)
    return if start_mileage.blank? || interval.blank?

    start_mileage + interval
  end
end