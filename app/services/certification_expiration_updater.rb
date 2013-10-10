class CertificationExpirationUpdater

  def self.update(certification)
    expiration_date = ExpirationCalculator.new.calculate(certification.last_certification_date, Interval.find_by_text(certification.interval))
    certification.update(expiration_date: expiration_date)
  end
end