module UsersHelper
  include PresentableModelHelper

  def user_accessible_parameters
    [
      :first_name,
      :last_name,
      :username,
      :email,
      :expiration_notification_interval,
      :customer_id,
      :password
    ]
  end
end