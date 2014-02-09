class CertotrackController < ApplicationController

  before_filter :load_equipment_service,
                :load_certification_service

  def home
    if can? :read, :equipment
      @total_equipment_count = @equipment_service.count_all_equipment(current_user)
      @expired_equipment_count = @equipment_service.count_expired_equipment(current_user)
      @expiring_equipment_count = @equipment_service.count_expiring_equipment(current_user)
    end

    if can? :read, :certification
      @total_certification_count = @certification_service.count_all_certifications(current_user)
      @total_expired_certification_count = @certification_service.count_expired_certifications(current_user)
      @total_expiring_certification_count = @certification_service.count_expiring_certifications(current_user)
      @total_units_based_certification_count = @certification_service.count_units_based_certifications(current_user)
      @total_recertification_required_certification_count = @certification_service.count_recertification_required_certifications(current_user)
    end

    @first_name = current_user.first_name
  end

  def load_equipment_service(service = EquipmentService.new)
    @equipment_service ||= service
  end

  def load_certification_service(service = CertificationService.new)
    @certification_service ||= service
  end
end