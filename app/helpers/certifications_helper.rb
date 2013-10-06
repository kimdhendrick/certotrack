module CertificationsHelper

  def certification_presenter_for(certification = @certification)
    presenter = CertificationPresenter.new(certification, self)
    yield presenter
  end
end