require 'spec_helper'

describe Customer do

  it { should have_many :users }
  it { should have_many :equipments }
  it { should have_many :certification_types }
  it { should have_many :certifications }
  it { should have_many :employees }
  it { should have_many :locations }
  it { should have_many :vehicles }
  it { should have_many :service_types }
  it { should have_many :services }
  it { should validate_presence_of :name }
  it { should validate_presence_of :contact_person_name }
  it { should validate_presence_of :contact_email }
  it { should validate_uniqueness_of :account_number }

  it 'should respond to its sort_key' do
    customer = build(:customer, name: 'MyCustomer')
    customer.sort_key.should == 'MyCustomer'
  end

  it 'should return roles list' do
    build(:customer, vehicle_access: true, certification_access: true, equipment_access: true).
      roles.should =~ ['vehicle', 'equipment', 'certification']

    build(:customer, vehicle_access: true, certification_access: false, equipment_access: true).
      roles.should =~ ['vehicle', 'equipment']

    build(:customer, vehicle_access: true, certification_access: false, equipment_access: false).
      roles.should == ['vehicle']

    build(:customer, vehicle_access: false, certification_access: false, equipment_access: true).
      roles.should == ['equipment']

    build(:customer, vehicle_access: false, certification_access: true, equipment_access: false).
      roles.should == ['certification']
  end

  describe 'when email has mixed case' do
    let(:customer) { create(:customer, contact_email: 'ABC@EMAIL.COM') }

    it 'should lowercase the email' do
      customer.contact_email.should == 'abc@email.com'
    end
  end

  describe 'when email format is invalid' do
    it 'should be invalid' do
      customer = build(:customer)
      addresses = %w[customer@foo,com customer_at_foo.org example.customer@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        customer.contact_email = invalid_address
        expect(customer).not_to be_valid
      end
    end
  end

  describe 'when email format is valid' do
    it 'should be valid' do
      customer = build(:customer)
      addresses = %w[customer@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        customer.contact_email = valid_address
        expect(customer).to be_valid
      end
    end
  end
end