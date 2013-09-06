module CertificationsHelper

  def units(certification)
    return '' unless certification.units_based?
    certification.units_achieved
  end
end