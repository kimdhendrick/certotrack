class UserPresenter
  include TruthHelper
  include LinkHelper

  attr_reader :model

  delegate :id,
           :username,
           :first_name,
           :last_name,
           :email,
           :expiration_notification_interval,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def sort_key
    username
  end

  def equipment_access
    yes_no(model.equipment_access?)
  end

  def certification_access
    yes_no(model.certification_access?)
  end

  def vehicle_access
    yes_no(model.vehicle_access?)
  end

  def customer_name
    model.customer.name
  end

  def customer
    model.customer
  end

  def name
    "#{last_name}, #{first_name}"
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_customer_user_path(model)
  end

  def delete_link
    @template.link_to 'Delete', @template.customer_user_path(model), method: :delete, data: {confirm: 'Are you sure you want to delete this user?'}
  end
end
