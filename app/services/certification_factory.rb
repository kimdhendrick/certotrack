class CertificationFactory

  def initialize(params = {})
    @expiration_calculator = params[:expiration_calculator] || ExpirationCalculator.new
  end

  def new_instance(attributes)
    employee_id = attributes[:employee_id]
    certification_type_id = attributes[:certification_type_id]
    customer = User.find(attributes[:current_user_id]).customer

    certification = Certification.new(employee_id: employee_id, certification_type_id: certification_type_id, customer: customer)
    certification = _build_certification_period(certification, attributes)
    certification.expiration_date = _expires_on(certification_type_id, certification.last_certification_date)
    certification
  end

  private

  def _build_certification_period(certification, attributes)
    certification_period_params =
      {
        certification: certification,
        start_date: attributes[:certification_date],
        trainer: attributes[:trainer],
        comments: attributes[:comments],
        units_achieved: attributes[:units_achieved]
      }

    active_certification_period = certification.create_active_certification_period(certification_period_params)

    if active_certification_period.valid?
      certification.certification_periods << active_certification_period
    end

    certification
  end

  def _expires_on(certification_type_id, certification_date)
    return nil if certification_date.blank? || certification_type_id.blank?

    certification_type = CertificationType.find(certification_type_id)
    Interval.find_by_text(certification_type.interval).from(certification_date)
  end
end