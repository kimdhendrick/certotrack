class CertotrackController < ApplicationController
  include ControllerHelper

  before_filter :load_equipment_service,
                :load_certification_service,
                :load_vehicle_servicing_service,
                :load_customer_service

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

    if can? :read, :vehicle
      @total_service_count = @vehicle_servicing_service.count_all_services(current_user)
      @total_expired_service_count = @vehicle_servicing_service.count_expired_services(current_user)
      @total_expiring_service_count = @vehicle_servicing_service.count_expiring_services(current_user)
    end

    if can? :read, :customer
      @customers = CustomerListPresenter.new(@customer_service.get_all_customers(current_user)).sort
    end

    @first_name = current_user.first_name
  end
end