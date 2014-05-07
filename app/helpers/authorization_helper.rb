module AuthorizationHelper

  def authorize_all(resources, action)
    resources.each { |resource| _authorize(resource, action) }
  end

  private

  def _authorize(resource, action)
    begin
      authorize! action, resource.class.name.underscore.to_sym
    rescue CanCan::AccessDenied
      authorize! action, resource
    end
  end
end