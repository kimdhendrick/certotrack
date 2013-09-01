class CertificationService

  def new_certification(employee_id)
    certification = Certification.new
    certification.active_certification_period = CertificationPeriod.new
    certification.employee = Employee.find(employee_id)
    certification
  end

  def certify(employee_id, certification_type_id, certification_date, trainer, comments)
    certification = Certification.new(employee_id: employee_id, certification_type_id: certification_type_id)
    certification.active_certification_period = _certification_period(certification, certification_date, comments, trainer)
    certification.expiration_date = _expires_on(certification_type_id, certification_date)
    certification.save
    certification
  end

  def load_expiration_calculator(calculator = ExpirationCalculator.new)
    @expiration_calculator ||= calculator
  end

  private

  def _expires_on(certification_type_id, certification_date)
    certification_type = CertificationType.find(certification_type_id)
    load_expiration_calculator.calculate(certification_date, certification_type.interval)
  end

  def _certification_period(certification, certification_date, comments, trainer)
    CertificationPeriod.new(certification: certification, start_date: certification_date, trainer: trainer, comments: comments)
  end
end