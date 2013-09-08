require 'spec_helper'

describe Location do
  before { @location = build(:location) }

  subject { @location }

  it { should belong_to(:customer) }
  it { should validate_presence_of :customer }
  it { should validate_uniqueness_of(:name).scoped_to(:customer_id) }

  describe 'uniqueness of name' do
    subject { create(:location, name: 'cat', customer: customer) }
    let(:customer) { create(:customer) }

    before do
      subject.valid?
    end

    it 'should not allow duplicate names when exact match' do
      copycat = Location.new(name: 'cat', customer: customer)
      copycat.should_not be_valid
      copycat.errors.full_messages_for(:name).should == ['Name has already been taken']
    end

    it 'should not allow duplicate names when differ by case' do
      copycat = Location.new(name: 'CAt', customer: customer)
      copycat.should_not be_valid
      copycat.errors.full_messages_for(:name).should == ['Name has already been taken']
    end

    it 'should not allow duplicate names when differ by leading space' do
      copycat = Location.new(name: ' cat', customer: customer)
      copycat.should_not be_valid
      copycat.errors.full_messages_for(:name).should == ['Name has already been taken']
    end

    it 'should not allow duplicate names when differ by trailing space' do
      copycat = Location.new(name: 'cat ', customer: customer)
      copycat.should_not be_valid
      copycat.errors.full_messages_for(:name).should == ['Name has already been taken']
    end
  end

  describe 'whitespace stripping' do
    it 'should strip trailing and leading whitespace' do
      customer = create(:customer)
      cat = create(:location, name: ' cat ', customer: customer)
      cat.reload
      cat.name.should == 'cat'
    end
  end

  it 'should display its name as to_s' do
    @location.name = 'My Location'
    @location.to_s.should == 'My Location'
  end
end
