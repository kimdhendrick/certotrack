class CertificationService

  def initialize(params = {})
    @certification_factory = params[:certification_factory] || CertificationFactory.new
  end

  def new_certification(employee_id, certification_type_id)
    @certification_factory.new_instance(
      employee_id: employee_id,
      certification_type_id: certification_type_id
    )
  end

  def certify(employee_id, certification_type_id, certification_date, trainer, comments, units_achieved)
    certification = @certification_factory.new_instance(
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

  def get_all_certifications_for_employee(employee)
    employee.certifications
  end

  def get_all_certifications_for_certification_type(certification_type)
    certification_type.certifications
  end

end