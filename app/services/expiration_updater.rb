class ExpirationUpdater

  def self.update_expiration_date(certification)
    new.update_expiration_date(certification)
  end

  def initialize(expiration_calculator = ExpirationCalculator.new)
    @expiration_calculator = expiration_calculator
  end

  def update_expiration_date(certification)
    certification.update_expiration_date
    certification.save
  end

  private

  attr_reader :expiration_calculator
end