class CertificationPeriodPresenter

  attr_reader :model

  delegate :trainer, to: :model

  def initialize(model, template = nil)
    @model = model
    @template = template
  end

  def active
    _active? ? 'Active' : ''
  end

  def last_certification_date
    DateHelpers.date_to_string model.start_date
  end

  def expiration_date
    DateHelpers.date_to_string model.end_date
  end

  def units
    return '' unless model.certification.units_based?
    "#{model.units_achieved} of #{model.certification.units_required}"
  end

  def status
    return '' if !_active?
    model.certification.status
  end

  def sort_key
    model.start_date
  end

  private

  def _active?
    model.certification.active_certification_period == model
  end
end