require 'spec_helper'

describe CertificationsHelper do

  it "should provide certifications's accessible parameters" do
    certification_accessible_parameters.should ==
      [
        :certification_type_id,
        :last_certification_date,
        :trainer,
        :comments,
        :units_achieved
      ]
  end
end
