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

  it 'should respond true to units_based?' do
    certification_type = create(:certification_type, units_required: 10, customer: create(:customer))
    CertificationTypePresenter.new(certification_type, nil).units_based?.should be_true
  end

  it 'should respond false to units_based?' do
    certification_type = create(:certification_type, customer: create(:customer))
    CertificationTypePresenter.new(certification_type, nil).units_based?.should be_false
  end

  it 'should respond to interval_code' do
    certification_type = create(
      :certification_type,
      customer: create(:customer),
      interval: Interval::THREE_MONTHS.text
    )

    CertificationTypePresenter.new(certification_type, nil).interval_code.should == Interval::THREE_MONTHS.id
  end

  it 'should respond to sort_key' do
    certification_type = create(:certification_type, customer: create(:customer), name: 'MyCertType')
    CertificationTypePresenter.new(certification_type, nil).sort_key.should == 'MyCertType'
  end

  it 'should respond to units_required_sort_key' do
    certification_type = build(:certification_type, units_required: 3)
    CertificationTypePresenter.new(certification_type).units_required_sort_key.should == 3
  end

  describe 'units_required' do
    context 'when Certification is date based' do
      it 'should be blank' do
        certification_type = build(:certification_type)
        CertificationTypePresenter.new(certification_type).units_required.should be_blank
      end
    end
    context 'when Certification is unit based' do
      it 'should be the value of #units_required of #units_required' do
        certification_type = build(:certification_type, units_required: 3)
        CertificationTypePresenter.new(certification_type).units_required.should == 3
      end
    end
  end

  describe 'units_required_label' do
    context 'when Certification is date based' do
      it 'should be blank' do
        certification_type = build(:certification_type)
        CertificationTypePresenter.new(certification_type).units_required_label.should be_blank
      end
    end
    context 'when Certification is unit based' do
      it 'should be the value of #units_required_label of #units_required' do
        certification_type = build(:certification_type, units_required: 3)
        CertificationTypePresenter.new(certification_type).units_required_label.should == 'Required Units'
      end
    end
  end

end