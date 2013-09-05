require 'service_support/sorting_and_pagination'

class CertificationService
  include ServiceSupport::SortingAndPagination

  def new_certification(employee_id)
    load_certification_factory.new_instance(employee_id)
  end

  def certify(employee_id, certification_type_id, certification_date, trainer, comments)
    certification = load_certification_factory.new_instance(employee_id, certification_type_id, certification_date, trainer, comments)
    certification.save
    certification
  end

  def load_certification_factory(factory = CertificationFactory.new)
    @certification_factory ||= factory
  end

  def get_all_certifications_for(employee, params = {})
    certifications = Certification.where(employee: employee)
    _sort_and_paginate(certifications, params)
  end
end