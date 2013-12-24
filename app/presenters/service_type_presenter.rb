class ServiceTypePresenter
  include ActionView::Helpers::NumberHelper

  attr_reader :model

  delegate :id, to: :model
  delegate :name, to: :model
  delegate :expiration_type, to: :model
  delegate :interval_date, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def interval_mileage
    number_with_delimiter(model.interval_mileage, :delimiter => ",")
  end

  def sort_key
    name
  end

  def interval_date_code
    Interval.lookup(interval_date)
  end

  def sortable_interval_mileage
    model.interval_mileage
  end

  def expiration_type_of_date?
    [ServiceType::EXPIRATION_TYPE_BY_DATE, ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE]
    .include?(model.expiration_type)
  end

  def expiration_type_of_mileage?
    [ServiceType::EXPIRATION_TYPE_BY_MILEAGE, ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE]
    .include?(model.expiration_type)
  end

  def edit_link
    @template.link_to 'Edit', @template.edit_service_type_path(model)
  end
end
