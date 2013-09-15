require 'spec_helper'

describe CertificationsHelper do
  describe '#units' do
    context 'when Certification is date based' do
      it 'should be blank' do
        certification = build(:certification)
        helper.units(certification).should be_blank
      end
    end
    context 'when Certification is unit based' do
      it 'should be the value of #units_achieved of #units_required' do
        certification = build(:units_based_certification)
        certification.certification_type.units_required = 3
        helper.units(certification).should == "1 of 3"
      end
    end
  end
end
