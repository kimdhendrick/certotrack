require 'spec_helper'

describe CertificationTypePresenter do
  it 'should respond to id' do
    certification_type = create(:certification_type)
    CertificationTypePresenter.new(certification_type, nil).id.should == certification_type.id
  end

  it 'should respond to name' do
    certification_type = create(:certification_type, name: 'My Name')
    CertificationTypePresenter.new(certification_type, nil).name.should == 'My Name'
  end

  it 'should respond to interval' do
    certification_type = create(
      :certification_type,
      customer: create(:customer),
      interval: Interval::THREE_MONTHS.text
    )
    CertificationPresenter.new(certification_type, nil).interval.should == '3 months'
  end
end