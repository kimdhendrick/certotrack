require 'spec_helper'

describe CertificationTypesHelper do

  it 'should provide accessible parameters' do
    certification_type_accessible_parameters.should == [
      :name,
      :inspection_interval,
      :units_required
    ]
  end
end