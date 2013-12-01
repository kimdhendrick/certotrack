module CertificationsHelper

  def certification_presenter_for(certification = @certification)
    presenter = CertificationPresenter.new(certification, self)
    yield presenter
  end

  def certification_accessible_parameters
    [
      :certification_type_id,
      :last_certification_date,
      :trainer,
      :comments,
      :units_achieved
    ]
  end
end