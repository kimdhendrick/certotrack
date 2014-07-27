class TrainingEventService

  def initialize(params = {})
    @certification_service = params[:certification_service] || CertificationService.new
    @employees_with_errors = []
    @certification_types_with_errors = []
  end

  def create_training_event(current_user, employee_ids, certification_type_ids, certification_date, trainer, comments)

    employee_ids.each do |employee_id|
      certification_type_ids.each do |certification_type_id|

        certification = _existing_certification(certification_type_id, employee_id)

        if certification.present?
          success = _recertify(certification, certification_date, trainer, comments)
        else
          certification = _certify(certification_date, certification_type_id, current_user, employee_id, trainer, comments)
          success = certification.valid?
        end

        unless success
          _append_error(certification)
        end
      end
    end

    {
      success: employees_with_errors.empty?,
      employees_with_errors: employees_with_errors,
      certification_types_with_errors: certification_types_with_errors
    }
  end

  private

  attr_reader :employees_with_errors, :certification_types_with_errors

  def _certify(certification_date, certification_type_id, current_user, employee_id, trainer, comments)
    @certification_service.certify(current_user, employee_id, certification_type_id, certification_date, trainer, comments, 0)
  end

  def _recertify(certification, certification_date, trainer, comments)
    @certification_service.recertify(certification, {start_date: certification_date, trainer: trainer, comments: comments})
  end

  def _existing_certification(certification_type_id, employee_id)
    Certification.where(employee_id: employee_id, certification_type_id: certification_type_id).first
  end

  def _append_error(certification)
    employees_with_errors << certification.employee
    certification_types_with_errors << certification.certification_type
  end
end