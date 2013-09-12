require 'spec_helper'

describe Employee do
  before { @employee = build(:employee) }

  subject { @employee }

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :employee_number }
  it { should validate_presence_of :customer }
  it { should validate_uniqueness_of(:employee_number).scoped_to(:customer_id) }
  it { should belong_to(:customer) }
  it { should belong_to(:location) }
  it { should have_many(:certifications) }
  it { should have_many(:equipments) }
  it_should_behave_like 'a stripped model', 'first_name'
  it_should_behave_like 'a stripped model', 'last_name'
  it_should_behave_like 'a stripped model', 'employee_number'

  describe 'uniqueness of employee_number' do
    let(:customer) { create(:customer) }

    before do
      create(:employee, employee_number: 'cat', customer: customer)
    end

    subject { Employee.new(customer: customer) }

    it_should_behave_like 'a model that prevents duplicates', 'cat', 'employee_number'
  end

  it 'should respond to its sort_key' do
    @employee.first_name = 'John'
    @employee.last_name = 'Doe'
    @employee.sort_key.should == 'DoeJohn'
  end

  it 'should display its name as to_s' do
    @employee.first_name = 'John'
    @employee.last_name = 'Doe'
    @employee.to_s.should == 'Doe, John'
  end

  it 'should respond to location_name' do
    location = create(:location, name: 'Location Name')
    employee = create(:employee, location_id: location.id)

    employee.location_name.should == 'Location Name'
  end

  it 'should default active to true' do
    employee = Employee.new
    employee.active.should be_true
  end
end