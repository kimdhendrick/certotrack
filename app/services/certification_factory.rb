class CertificationFactory

  def initialize(params = {})
    @expiration_calculator = params[:expiration_calculator] || ExpirationCalculator.new
  end

  def new_instance(attributes)
    employee_id = attributes[:employee_id]
    certification_type_id = attributes[:certification_type_id]
    certification_date = attributes[:certification_date]
    trainer = attributes[:trainer]
    comments = attributes[:comments]
    units_achieved = attributes[:units_achieved]

    employee = Employee.find_by_id(employee_id)
    certification_type = CertificationType.find_by_id(certification_type_id)
    customer = employee ? employee.customer : certification_type.customer

    certification = Certification.new(employee_id: employee_id, certification_type_id: certification_type_id, customer: customer)
    certification_period_params = {certification: certification, start_date: certification_date, trainer: trainer, comments: comments, units_achieved: units_achieved}
    certification.active_certification_period = CertificationPeriod.new(certification_period_params)
    certification.expiration_date = _expires_on(certification_type_id, certification.last_certification_date)
    certification
  end

  private

  def _expires_on(certification_type_id, certification_date)
    return nil if certification_date.blank? || certification_type_id.blank?
    certification_type = CertificationType.find(certification_type_id)
    @expiration_calculator.calculate(certification_date, Interval.find_by_text(certification_type.interval))
  end
end
