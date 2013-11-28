require 'spec_helper'

describe Location do
  let(:location) { build(:location) }

  subject { location }

  it { should belong_to(:customer) }
  it { should have_many(:equipments) }
  it { should have_many(:employees) }
  it { should validate_presence_of :customer }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:customer_id) }
  it_should_behave_like 'a stripped model', 'name'

  describe 'uniqueness of name' do
    let(:customer) { create(:customer) }

    before do
      create(:location, name: 'cat', customer: customer)
    end

    subject { Location.new(customer: customer) }

    it_should_behave_like 'a model that prevents duplicates', 'cat', 'name'
  end

  it 'should display its name as to_s' do
    location.name = 'My Location'
    location.to_s.should == 'My Location'
  end

  it 'should respond to its sort_key' do
    location.name = 'My Location'
    location.sort_key.should == 'My Location'
  end
end
