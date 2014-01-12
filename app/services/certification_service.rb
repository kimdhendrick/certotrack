class CertificationService

  def initialize(params = {})
    @certification_factory = params[:certification_factory] || CertificationFactory.new
    @search_service = params[:search_service] || SearchService.new
  end

  def get_all_certifications(current_user)
    current_user.admin? ?
        Certification.all :
        current_user.certifications
  end

  def count_all_certifications(current_user)
    current_user.admin? ?
        Certification.count :
        current_user.certifications.count
  end

  def search_certifications(current_user, params)
    certifications = []

    if current_user.admin?
      certifications = Certification.all.joins(:certification_type).joins(:employee)
    else
      certifications = current_user.certifications.joins(:certification_type).joins(:employee)
    end

    @search_service.search(certifications, params)
  end

  def count_expired_certifications(current_user)
    get_expired_certifications(current_user).count
  end

  def count_expiring_certifications(current_user)
    get_expiring_certifications(current_user).count
  end

  def count_units_based_certifications(current_user)
    get_units_based_certifications(current_user).count
  end

  def count_recertification_required_certifications(current_user)
    get_recertification_required_certifications(current_user).count
  end

  def get_expired_certifications(current_user)
    get_all_certifications(current_user).select { |e| e.expired? }
  end

  def get_expiring_certifications(current_user)
    get_all_certifications(current_user).select { |e| e.expiring? }
  end

  def get_units_based_certifications(current_user)
    get_all_certifications(current_user).select { |e| e.units_based? }
  end

  def get_recertification_required_certifications(current_user)
    get_all_certifications(current_user).select { |e| e.recertification_required? }
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
    ExpirationUpdater.update_expiration_date(certification)
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

  def recertify(certification, attributes)
    certification.recertify(attributes)
    certification.save
  end

  def auto_recertify(certifications)

    success = true

    ActiveRecord::Base.transaction do
      certifications.each do |certification|
        certification.recertify(trainer: certification.trainer, start_date: certification.expiration_date)
        success = certification.save
        raise ActiveRecord::Rollback unless success
      end
    end

    success ? :success : :failure
  end
end