class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :welcome_user

  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def welcome_user
    if user_signed_in?
      @first_name = current_user.first_name.strip
      @customer_name = current_user.customer.name.strip
    end
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end
end
