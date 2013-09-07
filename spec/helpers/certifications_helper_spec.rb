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
      it 'should be the value of #units_achieved' do
        certification = build(:units_based_certification)
        helper.units(certification).should == 1
      end
    end
  end
end
