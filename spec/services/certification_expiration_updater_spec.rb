require 'spec_helper'

describe CertificationExpirationUpdater do
  describe '.update' do
    it 'should update certification expiration date' do
      certification_type = create(:certification_type, interval: Interval::FIVE_YEARS.text)
      certification = create(
        :certification,
        certification_type: certification_type,
        last_certification_date: '2012-03-29'.to_date,
        expiration_date: '2000-01-01'.to_date
      )

      CertificationExpirationUpdater.update(certification)

      certification.reload
      certification.expiration_date.should == '2017-03-29'.to_date
    end
  end
end