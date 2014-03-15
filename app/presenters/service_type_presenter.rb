class ServiceTypePresenter
  include ActionView::Helpers::NumberHelper
  include LinkHelper

  attr_reader :model

  delegate :id,
           :name,
           :expiration_type,
           :interval_date,
           :mileage_expiration_type?,
           :date_expiration_type?,
           to: :model

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

  def edit_link
    @template.link_to 'Edit', @template.edit_service_type_path(model)
  end

  def delete_link
    confirm_delete_link 'Are you sure you want to delete this service type?'
  end
end
