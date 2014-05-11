class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :welcome_user

  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def welcome_user
    @logged_in = current_user.present?

    if @logged_in
      @first_name = current_user.first_name
      @customer_name = current_user.customer.name
    end
  end
end
