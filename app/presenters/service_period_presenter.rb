class ServicePeriodPresenter
  include ActionView::Helpers::NumberHelper
  include PeriodPresenter

  attr_reader :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def last_service_date
    model_start_date
  end

  def expiration_date
    return '' unless _parent.date_expiration_type?
    DateHelpers.date_to_string model.end_date
  end

  def last_service_mileage
    number_with_delimiter(model.start_mileage, delimiter: ',')
  end

  def expiration_mileage
    return '' unless _parent.mileage_expiration_type?

    number_with_delimiter(model.end_mileage, delimiter: ',')
  end

  private

  def _parent
    model.service
  end

  def _active?
    _parent.active_service_period == model
  end
end