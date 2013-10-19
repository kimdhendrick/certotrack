class BatchCertification
  include CertificationTypesHelper
  include EmployeesHelper

  attr_reader :certification_attributes,
              :certifications,
              :employee,
              :certification_type,
              :non_certified_employees

  def initialize(attributes, certification_service = CertificationService.new, employee_service = EmployeeService.new)
    @certification_service = certification_service
    @employee_service = employee_service

    _update_by_employee?(attributes) ?
      _initialize_by_employee(attributes) :
      _initialize_by_certification_type(attributes)

    @certification_attributes = _collect_certification_units(attributes)

    @errors = {}
    @units = {}
  end

  def update
    success = true

    certification_attributes.each do |certification_hash|
      certification = Certification.find(certification_hash[:certification_id])

      begin
        Certification.transaction do
          @units[certification.id] = certification_hash[:units_achieved]
          certification.update_attributes!(units_achieved: certification_hash[:units_achieved])
        end
      rescue ActiveRecord::RecordInvalid
        @errors[certification.id] = certification.errors.full_messages
        success = false
      end

    end
    success
  end

  def employee_update?
    @update_by_employee
  end

  def units(certification_id)
    @units[certification_id]
  end

  def error(certification_id)
    return if @errors[certification_id].nil?
    @errors[certification_id].join(',')
  end

  private

  def _update_by_employee?(attributes)
    @update_by_employee = attributes[:employee_id].present?
  end

  def _collect_certification_units(attributes)
    attributes[:certification_ids].collect do |certification_units_list|
      {
        certification_id: certification_units_list[0].to_i,
        units_achieved: certification_units_list[1]
      }
    end
  end

  def _initialize_by_certification_type(attributes)
    @update_by_employee = false
    @certification_type = CertificationType.find(attributes[:certification_type_id])

    assign_certifications_by_certification_type
    assign_non_certified_employees_by_certification_type
  end

  def _initialize_by_employee(attributes)
    @update_by_employee = true

    @employee = Employee.find(attributes[:employee_id])
    assign_certifications_by_employee
  end
end