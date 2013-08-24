class CertificationTypesService

  def create_certification_type(customer, attributes)
    certification_type = CertificationType.new(attributes)
    certification_type.customer = customer
    certification_type.save
    certification_type
  end

  def update_certification_type(certification_type, attributes)
    certification_type.update(attributes)
    certification_type.save
  end

  def delete_certification_type(certification_type)
    certification_type.destroy
  end
end