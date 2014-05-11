class CertotrackController < ApplicationController
  include ControllerHelper

  before_filter :load_equipment_service,
                :load_certification_service,
                :load_vehicle_servicing_service,
                :load_customer_service

  def home
    if can? :read, :equipment
      equipment = @equipment_service.get_all_equipment(current_user)
      @total_equipment_count = equipment.count
      @expired_equipment_count = _count(equipment, :expired?)
      @expiring_equipment_count = _count(equipment, :expiring?)
    end

    if can? :read, :certification
      certifications = @certification_service.get_all_certifications(current_user)
      @total_certification_count = certifications.count
      @total_expired_certification_count = _count(certifications, :expired?)
      @total_expiring_certification_count = _count(certifications, :expiring?)
      @total_units_based_certification_count = _count(certifications, :units_based?)
      @total_recertification_required_certification_count = _count(certifications, :recertification_required?)
    end

    if can? :read, :vehicle
      services = @vehicle_servicing_service.get_all_services(current_user)
      @total_service_count = services.count
      @total_expired_service_count = _count(services, :expired?)
      @total_expiring_service_count = _count(services, :expiring?)
    end

    if can? :read, :customer
      @customers = CustomerListPresenter.new(@customer_service.get_all_customers(current_user)).sort
    end
  end

  private

  def _count(collection, question)
    collection.select { |certification| certification.public_send(question) }.count
  end
end