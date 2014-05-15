class CertotrackController < ApplicationController
  include ControllerHelper

  before_filter :load_equipment_service,
                :load_certification_service,
                :load_vehicle_servicing_service,
                :load_customer_service

  def home
    if can? :read, :equipment
      if session[:counts_cached].nil?
        equipment = @equipment_service.get_all_equipment(current_user)
        session[:total_equipment_count] = equipment.count
        session[:expired_equipment_count] = _count(equipment, :expired?)
        session[:expiring_equipment_count] = _count(equipment, :expiring?)
      end

      @total_equipment_count = session[:total_equipment_count]
      @expired_equipment_count = session[:expired_equipment_count]
      @expiring_equipment_count = session[:expiring_equipment_count]
    end

    if can? :read, :certification
      if session[:counts_cached].nil?
        certifications = @certification_service.get_all_certifications(current_user)
        session[:total_certification_count] = certifications.count
        session[:total_expired_certification_count] = _count(certifications, :expired?)
        session[:total_expiring_certification_count] = _count(certifications, :expiring?)
        session[:total_units_based_certification_count] = _count(certifications, :units_based?)
        session[:total_recertification_required_certification_count] = _count(certifications, :recertification_required?)
      end

      @total_certification_count = session[:total_certification_count]
      @total_expired_certification_count = session[:total_expired_certification_count]
      @total_expiring_certification_count = session[:total_expiring_certification_count]
      @total_units_based_certification_count = session[:total_units_based_certification_count]
      @total_recertification_required_certification_count = session[:total_recertification_required_certification_count]
    end

    if can? :read, :vehicle
      if session[:counts_cached].nil?
        services = @vehicle_servicing_service.get_all_services(current_user)
        session[:total_service_count] = services.count
        session[:total_expired_service_count] = _count(services, :expired?)
        session[:total_expiring_service_count] = _count(services, :expiring?)
      end

      @total_service_count = session[:total_service_count]
      @total_expired_service_count = session[:total_expired_service_count]
      @total_expiring_service_count = session[:total_expiring_service_count]
    end

    if can? :read, :customer
      @customers = CustomerListPresenter.new(@customer_service.get_all_customers(current_user)).sort
    end

    session[:counts_cached] = true
  end

  def refresh
    session[:counts_cached] = nil

    redirect_to dashboard_url
  end

  private

  def _count(collection, question)
    collection.select { |certification| certification.public_send(question) }.count
  end
end