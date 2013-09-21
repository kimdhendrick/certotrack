class CertificationTypeService

  def initialize(params = {})
    @search_service = params[:search_service] || SearchService.new
    @sorter = params[:sorter] || Sorter.new
    @paginator = params[:paginator] || Paginator.new
  end

  def get_all_certification_types(user, params = {})
    certification_types = _get_certification_types_for_user(user)
    @sorter.sort(certification_types, params[:sort], params[:direction])
  end

  def get_certification_type_list(user, params = {})
    certification_types = _get_certification_types_for_user(user)
    certification_types = @search_service.search(certification_types, params)
    certification_types = @sorter.sort(certification_types, params[:sort], params[:direction])
    @paginator.paginate(certification_types, params[:page])
  end

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
    if certification_type.certifications.any?
      return :certification_exists
    end

    certification_type.destroy
  end

  private

  def _get_certification_types_for_user(user)
    user.admin? ? CertificationType.all : user.certification_types
  end
end