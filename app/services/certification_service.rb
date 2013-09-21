require 'service_support/sorting_and_pagination'

class CertificationService
  include ServiceSupport::SortingAndPagination

  def initialize(params = {})
    @certification_factory = params[:certification_factory] || CertificationFactory.new
    @sorter = params[:sorter] || Sorter.new
    @paginator = params[:paginator] || Paginator.new
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

  def get_all_certifications_for_employee(employee, params = {})
    certifications = employee.certifications
    _sort_and_paginate(certifications, params)
  end

  def get_all_certifications_for_certification_type(certification_type, params = {})
    certifications = certification_type.certifications
    _sort_and_paginate(certifications, params)
  end

end