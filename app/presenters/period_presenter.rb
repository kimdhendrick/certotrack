module PeriodPresenter
  def active
    _active? ? 'Active' : ''
  end

  def status
    return '' if !_active?
    _parent.status
  end

  def sort_key
    model.start_date
  end

  def model_start_date
    DateHelpers.date_to_string model.start_date
  end
end