class BatchCertification

  attr_reader :certification_attributes,
              :employee,
              :certifications

  def initialize(attributes)
    @employee = Employee.find(attributes[:employee_id])

    @certifications =
      CertificationListPresenter.new(CertificationService.new.get_all_certifications_for_employee(@employee)).present

    @certification_attributes =
      attributes[:certification_ids].collect do |pair|
        {certification_id: pair[0].to_i, units_achieved: pair[1]}
      end

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

  def units(certification_id)
    @units[certification_id]
  end

  def error(certification_id)
    return if @errors[certification_id].nil?

    @errors[certification_id].join(',')
  end
end