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
end