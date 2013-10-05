module CertificationsHelper

  def certification_presenter_for(certification = @certification)
    presenter = CertificationPresenter.new(certification, self)
    if block_given?
      yield presenter
    else
      presenter
    end
  end

  #TODO KDB
  def units(certification)
    return '' unless certification.units_based?
    "#{certification.units_achieved} of #{certification.units_required}"
  end
end