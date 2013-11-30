module CertificationsHelper
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