class CustomerPresenter
  include TruthHelper

  attr_reader :model

  delegate :id,
           :name,
           :account_number,
           :contact_person_name,
           :contact_phone_number,
           :contact_email,
           :address1,
           :address2,
           :city,
           :state,
           :zip,
           to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def sort_key
    name
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

  def active
    yes_no(model.active?)
  end

  def locations
    LocationListPresenter.new(model.locations).sort
  end

  def users
    UserListPresenter.new(model.users).sort
  end

  def created_at
    DateHelpers::date_to_string(model.created_at)
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_customer_path(model)
  end
end
