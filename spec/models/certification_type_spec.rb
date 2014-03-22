require 'spec_helper'

describe CertificationType do
  let(:certification_type) { build(:certification_type) }

  subject { certification_type }

  it { should validate_presence_of :name }
  it { should validate_presence_of :customer }
  it { should validate_presence_of :created_by }
  it { should belong_to(:customer) }
  it { should validate_uniqueness_of(:name).scoped_to(:customer_id) }
  it { should have_many :certifications }
  it_should_behave_like 'a stripped model', 'name'

  describe 'uniqueness of name' do
    let(:customer) { create(:customer) }

    before do
      create(:certification_type, name: 'cat', customer: customer)
    end

    subject { CertificationType.new(customer: customer) }

    it_should_behave_like 'a model that prevents duplicates', 'cat', 'name'
  end

  it 'should default units_required to 0' do
    certification_type = CertificationType.new
    certification_type.units_required.should == 0
  end

  it 'should not allow negative numbers for units_required' do
    build(:certification_type, units_required: -1).should_not be_valid
    build(:certification_type, units_required: 0).should be_valid
    build(:certification_type, units_required: 1).should be_valid
  end

  it 'should only accept valid intervals' do
    build(:certification_type, interval: Interval::ONE_MONTH.text).should be_valid
    build(:certification_type, interval: Interval::THREE_MONTHS.text).should be_valid
    build(:certification_type, interval: Interval::SIX_MONTHS.text).should be_valid
    build(:certification_type, interval: Interval::ONE_YEAR.text).should be_valid
    build(:certification_type, interval: Interval::TWO_YEARS.text).should be_valid
    build(:certification_type, interval: Interval::FIVE_YEARS.text).should be_valid
    build(:certification_type, interval: Interval::NOT_REQUIRED.text).should be_valid

    build(:certification_type, interval: 'blah').should_not be_valid
  end

  it 'should respond to units_based?' do
    build(:certification_type, units_required: 0).should_not be_units_based
    build(:certification_type, units_required: 1).should be_units_based
  end

  describe '#has_valid_certification?' do
    let(:certification_type) { create(:units_based_certification_type) }

    before do
      @certification = create(:units_based_certification, certification_type: certification_type, units_achieved:
          certification_type.units_required)
    end

    context 'when no Certifications exist' do
      before { Certification.destroy_all }

      it 'should be false' do
        certification_type.should_not have_valid_certification
      end
    end

    context 'when no valid Certifications exist' do
      before { @certification.update_attribute(:units_achieved, certification_type.units_required - 1) }

      it 'should be false' do
        certification_type.should_not have_valid_certification
      end
    end

    context 'when a valid Certification exists' do
      it 'should be true' do
        certification_type.should have_valid_certification
      end
    end
  end

  describe '#valid_certifications' do
    let(:certification_type) { create(:units_based_certification_type) }

    before do
      @certification = create(:units_based_certification, certification_type: certification_type, units_achieved:
          certification_type.units_required)
    end

    context 'when no Certifications exist' do
      before { Certification.destroy_all }

      it 'should be false' do
        certification_type.valid_certifications.should == []
      end
    end

    context 'when no valid Certifications exist' do
      before { @certification.update_attribute(:units_achieved, certification_type.units_required - 1) }

      it 'should be false' do
        certification_type.valid_certifications.should == []
      end
    end

    context 'when a valid Certification exists' do
      it 'should be true' do
        certification_type.valid_certifications.should == [@certification]
      end
    end
  end

  describe '#destroy' do
    before { certification_type.save }

    context 'when certification type has no certifications' do
      it 'should destroy certification type' do
        expect { certification_type.destroy }.to change(CertificationType, :count).by(-1)
      end
    end

    context 'when certification type has one or more certifications' do
      before { create(:certification, certification_type: certification_type) }

      it 'should not destroy certification type' do
        expect { certification_type.destroy }.to_not change(CertificationType, :count).by(-1)
      end

      it 'should have a base error' do
        certification_type.destroy

        certification_type.errors[:base].first.should == 'This Certification Type is assigned to existing Employee(s). You must uncertify the employee(s) before removing it.'
      end
    end
  end
end