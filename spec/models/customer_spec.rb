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
end