class UserPresenter
  include TruthHelper

  attr_reader :model

  delegate :id,
           :username,
           :first_name,
           :last_name,
           :email,
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
end
