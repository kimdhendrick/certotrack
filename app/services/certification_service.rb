class CertificationService

  def initialize(params = {})
    @certification_factory = params[:certification_factory] || CertificationFactory.new
  end

  def new_certification(current_user, employee_id, certification_type_id)
    @certification_factory.new_instance(
      current_user_id: current_user.id,
      employee_id: employee_id,
      certification_type_id: certification_type_id
    )
  end

  def certify(current_user, employee_id, certification_type_id, certification_date, trainer, comments, units_achieved)
    certification = @certification_factory.new_instance(
      current_user_id: current_user.id,
      employee_id: employee_id,
      certification_type_id: certification_type_id,
      certification_date: certification_date,
      trainer: trainer,
      comments: comments,
      units_achieved: units_achieved
    )
    certification.save
    certification
  end

  def update_certification(certification, attributes)
    certification.update(attributes)
    certification.update(expiration_date: _expires_on(certification))
  end

  def get_all_certifications_for_employee(employee)
    employee.certifications
  end

  def get_all_certifications_for_certification_type(certification_type)
    certification_type.certifications
  end

  private

  def _expires_on(certification)
    ExpirationCalculator.new.calculate(certification.last_certification_date, Interval.find_by_text(certification.interval))
  end
end