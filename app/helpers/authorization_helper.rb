module AuthorizationHelper
  def authorize(resource, action)
    authorize! action, resource
  end

  def authorize_all(resources, action)
    resources.each { |resource| authorize(resource, action) }
  end
end