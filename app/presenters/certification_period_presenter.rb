class CertificationPeriodPresenter
  include PeriodPresenter

  attr_reader :model

  delegate :trainer, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def last_certification_date
    model_start_date
  end

  def expiration_date
    DateHelpers.date_to_string model.end_date
  end

  def units
    return '' unless model.certification.units_based?
    "#{model.units_achieved} of #{model.certification.units_required}"
  end

  def sort_key
    model.start_date
  end

  private

  def _parent
    model.certification
  end

  def _active?
    _parent.active_certification_period == model
  end
end