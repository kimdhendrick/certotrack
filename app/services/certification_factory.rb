class CertificationFactory

  def new_instance(employee_id, certification_type_id = nil, certification_date = nil, trainer = nil, comments = nil)
    certification = Certification.new(employee_id: employee_id, certification_type_id: certification_type_id)
    certification.active_certification_period = CertificationPeriod.new(certification: certification, start_date: certification_date, trainer: trainer, comments: comments)
    certification.expiration_date = _expires_on(certification_type_id, certification.last_certification_date)
    certification
  end

  def load_expiration_calculator(calculator = ExpirationCalculator.new)
    @expiration_calculator ||= calculator
  end

  private

  def _expires_on(certification_type_id, certification_date)
    return nil if certification_date.blank? || certification_type_id.blank?
    certification_type = CertificationType.find(certification_type_id)
    load_expiration_calculator.calculate(certification_date, Interval.find_by_text(certification_type.interval))
  end
end
