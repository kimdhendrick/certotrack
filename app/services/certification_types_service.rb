class CertificationTypesService

  def create_certification_type(customer, attributes)
    certification_type = CertificationType.new(attributes)
    certification_type.customer = customer
    certification_type
  end
end