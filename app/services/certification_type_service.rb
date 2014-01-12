class CertificationTypeService

  def initialize(params = {})
    @search_service = params[:search_service] || SearchService.new
  end

  def get_all_certification_types(user)
    user.admin? ? CertificationType.all : user.certification_types
  end

  def find(certification_type_ids, user)
    certification_types = CertificationType.find(certification_type_ids)

    return certification_types if user.admin?

    certification_types.select { |certification_type| certification_type.customer == user.customer }
  end

  def search_certification_types(user, params = {})
    @search_service.search(get_all_certification_types(user), params)
  end

  def create_certification_type(customer, attributes)
    certification_type = CertificationType.new(attributes)
    certification_type.customer = customer
    certification_type.save
    certification_type
  end

  def update_certification_type(certification_type, attributes)
    certification_type.update(attributes)
    certification_type.certifications.each do |certification|
      ExpirationUpdater.update_expiration_date(certification)
    end
    certification_type.save
  end

  def delete_certification_type(certification_type)
    if certification_type.certifications.any?
      return :certification_exists
    end

    certification_type.destroy
  end
end