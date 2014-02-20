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

  describe '#destroy' do
    before { location.save }

    context 'when location has no employees or equipment assigned' do
      it 'should destroy location' do
        expect { location.destroy }.to change(Location, :count).by(-1)
      end
    end

    context 'when location has one or more employees' do
      before { create(:employee, location: location) }

      it 'should not destroy location' do
        expect { location.destroy }.to_not change(Location, :count).by(-1)
      end

      it 'should have a base error' do
        location.destroy

        location.errors[:base].first.should == 'Location has employees assigned, you must reassign them before deleting the location.'
      end
    end

    context 'when location has one or more pieces of equipment' do
      before { create(:equipment, location: location) }

      it 'should not destroy location' do
        expect { location.destroy }.to_not change(Location, :count).by(-1)
      end

      it 'should have a base error' do
        location.destroy

        location.errors[:base].first.should == 'Location has equipment assigned, you must reassign them before deleting the location.'
      end
    end

    context 'when location has one or more employees and pieces of equipment' do
      before do
        create(:equipment, location: location)
        create(:employee, location: location)
      end

      it 'should not destroy location' do
        expect { location.destroy }.to_not change(Location, :count).by(-1)
      end

      it 'should have base errors' do
        location.destroy

        location.errors[:base].should include 'Location has employees assigned, you must reassign them before deleting the location.'
        location.errors[:base].should include 'Location has equipment assigned, you must reassign them before deleting the location.'
      end
    end
  end
end
