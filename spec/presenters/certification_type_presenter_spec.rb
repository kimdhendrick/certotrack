require 'spec_helper'

describe CertificationTypePresenter do
  let(:customer) { create(:customer) }
  let(:interval) { Interval::THREE_MONTHS.text }
  let(:units_required) { 10 }
  let(:name) { 'My Name' }
  let(:certification_type) do
    create(:units_based_certification_type, customer: customer, interval: interval,
           units_required: units_required, name: name)
  end

  subject { CertificationTypePresenter.new(certification_type, view) }

  it 'should respond to id' do
    subject.id.should == certification_type.id
  end

  it 'should respond to name' do
    subject.name.should == 'My Name'
  end

  it 'should respond to interval' do
    subject.interval.should == '3 months'
  end

  describe '#units_based?' do
    context 'when Certification Type is units based' do
      it 'should respond true to units_based?' do
        subject.units_based?.should be_true
      end
    end

    context 'when Certification Type is not units based' do
      let(:certification_type) do
        create(:date_based_certification_type, customer: customer, interval: interval, name: name)
      end

      it 'should respond false to units_based?' do
        subject.units_based?.should be_false
      end
    end
  end

  it 'should respond true to show_batch_edit_button?' do
    certification = build(:certification, certification_type: certification_type)
    subject.show_batch_edit_button?([certification]).should be_true
  end

  it 'should respond false to show_batch_edit_button?' do
    subject.show_batch_edit_button?([]).should be_false
  end

  it 'should respond to interval_code' do
    subject.interval_code.should == Interval::THREE_MONTHS.id
  end

  it 'should respond to sort_key' do
    subject.sort_key.should == 'My Name'
  end

  it 'should respond to units_required_sort_key' do
    subject.units_required_sort_key.should == 10
  end

  describe '#auto_recertify_link' do
    let(:certification_type) { double('certification_type') }

    before do
      certification_type.stub(:to_s).and_return(1)
    end

    context 'when Certification Type is units based' do
      before { certification_type.stub(:units_based?).and_return(true) }

      context 'when has no valid certifications' do
        before { certification_type.stub(:has_valid_certification?).and_return(false) }

        it 'should be blank' do
          subject.auto_recertify_link.should == ''
        end
      end

      context 'when has valid certification' do
        before { certification_type.stub(:has_valid_certification?).and_return(true) }

        it 'should return the link to Auto Recertify' do
          subject.auto_recertify_link.should == "<a href=\"/certification_types/1/auto_recertify\">Auto Recertify</a>"
        end
      end
    end

    context 'when Certification Type is not units based' do
      before { certification_type.stub(:units_based?).and_return(false) }

      it 'should be blank' do
        subject.auto_recertify_link.should == ''
      end
    end
  end

  describe 'units_required' do

    context 'when Certification is date based' do
      let(:certification_type) do
        create(:date_based_certification_type, customer: customer, interval: interval, name: name)
      end

      it 'should be blank' do
        subject.units_required.should be_blank
      end
    end

    context 'when Certification is unit based' do

      it 'should be the value of #units_required of #units_required' do
        subject.units_required.should == 10
      end
    end
  end

  describe 'units_required_label' do

    context 'when Certification is date based' do
      let(:certification_type) do
        create(:date_based_certification_type, customer: customer, interval: interval, name: name)
      end

      it 'should be blank' do
        subject.units_required_label.should be_blank
      end
    end

    context 'when Certification is unit based' do

      it 'should be the value of #units_required_label of #units_required' do
        subject.units_required_label.should == 'Required Units'
      end
    end
  end
end