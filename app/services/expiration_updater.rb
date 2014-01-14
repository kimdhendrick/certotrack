class ExpirationUpdater

  def self.update_expiration_date(certification)
    new.update_expiration_date(certification)
  end

  def self.update_expiration_date_and_mileage(service)
    new.update_expiration_date_and_mileage(service)
  end

  def initialize(expiration_calculator = ExpirationCalculator.new)
    @expiration_calculator = expiration_calculator
  end

  def update_expiration_date(certification)
    certification.update_expiration_date
    certification.save
  end

  def update_expiration_date_and_mileage(service)
    interval = Interval.find_by_text(service.interval_date)
    expiration_date = interval.from(service.last_service_date) if interval
    service.update(expiration_date: expiration_date)

    expiration_mileage = expiration_calculator.calculate_mileage(service.last_service_mileage, service.interval_mileage)
    service.update(expiration_mileage: expiration_mileage)
  end

  private

  attr_reader :expiration_calculator
end