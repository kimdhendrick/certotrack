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

  describe 'uniqueness of name' do
    subject { create(:employee, employee_number: 'cat', customer: customer) }
    let(:customer) { create(:customer) }

    before do
      subject.valid?
    end

    it 'should not allow duplicate names when exact match' do
      copycat = Employee.new(employee_number: 'cat', customer: customer)
      copycat.should_not be_valid
      copycat.errors.full_messages_for(:employee_number).should == ['Employee number has already been taken']
    end

    it 'should not allow duplicate employee_numbers when differ by case' do
      copycat = Employee.new(employee_number: 'CAt', customer: customer)
      copycat.should_not be_valid
      copycat.errors.full_messages_for(:employee_number).should == ['Employee number has already been taken']
    end

    it 'should not allow duplicate employee_numbers when differ by leading space' do
      copycat = Employee.new(employee_number: ' cat', customer: customer)
      copycat.should_not be_valid
      copycat.errors.full_messages_for(:employee_number).should == ['Employee number has already been taken']
    end

    it 'should not allow duplicate employee_numbers when differ by trailing space' do
      copycat = Employee.new(employee_number: 'cat ', customer: customer)
      copycat.should_not be_valid
      copycat.errors.full_messages_for(:employee_number).should == ['Employee number has already been taken']
    end
  end

  describe 'whitespace stripping' do
    it 'should strip trailing and leading whitespace' do
      customer = create(:customer)
      cat = create(:employee, employee_number: ' cat ', customer: customer)
      cat.reload
      cat.employee_number.should == 'cat'
    end
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