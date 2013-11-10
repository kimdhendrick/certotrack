module AuthorizationHelper

  def authorize_all(resources, action)
    resources.each { |resource| _authorize(resource, action) }
  end

  private

  def _authorize(resource, action)
    authorize! action, resource
  end
end