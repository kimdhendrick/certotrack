require 'spec_helper'

describe CertificationType do
  let(:certification_type) { build(:certification_type) }

  subject { certification_type }

  it { should validate_presence_of :name }
  it { should validate_presence_of :customer }
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
end