class CertificationTypeService

  def initialize(params = {})
    @search_service = params[:search_service] || SearchService.new
    @sort_service = params[:sort_service] || SortService.new
    @pagination_service = params[:pagination_service] || PaginationService.new
  end

  def get_all_certification_types(user)
    user.admin? ? CertificationType.all : user.certification_types
  end

  def get_certification_type_list(user, params = {})
    certification_types = get_all_certification_types(user)
    certification_types = @search_service.search(certification_types, params)
    certification_types = @sort_service.sort(certification_types, params[:sort], params[:direction])
    @pagination_service.paginate(certification_types, params[:page])
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
    certification_type.destroy
  end
end