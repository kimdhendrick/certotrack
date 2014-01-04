class ServicePresenter
  include ActionView::Helpers::NumberHelper

  attr_reader :model

  delegate :id, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def service_type_name
    model.name
  end

  def service_due_date
    DateHelpers.date_to_string model.expiration_date
  end

  def service_due_mileage
    number_with_delimiter(model.expiration_mileage, :delimiter => ",")
  end

  def last_service_date
    DateHelpers.date_to_string model.last_service_date
  end

  def last_service_mileage
    number_with_delimiter(model.last_service_mileage, :delimiter => ",")
  end

  def sort_key
    model.name
  end
end
