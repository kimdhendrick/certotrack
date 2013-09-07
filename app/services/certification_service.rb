require 'service_support/sorting_and_pagination'

class CertificationService
  include ServiceSupport::SortingAndPagination

  def initialize(params = {})
    @certification_factory = params[:certification_factory] || CertificationFactory.new
    @sort_service = params[:sort_service] || SortService.new
    @pagination_service = params[:pagination_service] || PaginationService.new
  end

  def new_certification(employee_id)
    @certification_factory.new_instance(employee_id)
  end

  def certify(employee_id, certification_type_id, certification_date, trainer, comments)
    certification = @certification_factory.new_instance(employee_id, certification_type_id, certification_date, trainer, comments)
    certification.save
    certification
  end

  def get_all_certifications_for(employee, params = {})
    certifications = employee.certifications
    _sort_and_paginate(certifications, params)
  end
end