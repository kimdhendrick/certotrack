module CertificationsHelper

  def certification_presenter_for(certification = @certification)
    presenter = CertificationPresenter.new(certification, self)
    if block_given?
      yield presenter
    else
      presenter
    end
  end
end