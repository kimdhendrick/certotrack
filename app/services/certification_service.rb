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
    CertificationExpirationUpdater.update(certification)
  end

  def delete_certification(certification)
    certification.destroy
  end

  def get_all_certifications_for_employee(employee)
    employee.certifications
  end

  def get_all_certifications_for_certification_type(certification_type)
    certification_type.certifications
  end
end