require 'spec_helper'

describe ServiceTypePresenter do

  let(:service_type) do
    build(:service_type,
          name: 'Oil Change',
          expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
          interval_date: Interval::ONE_MONTH.text,
          interval_mileage: 5000,
          customer: create(:customer, name: 'myCustomer'))
  end

  subject { ServiceTypePresenter.new(create(:service_type)) }

  it 'should respond to model' do
    ServiceTypePresenter.new(service_type).model.should == service_type
  end

  it 'should respond to id' do
    ServiceTypePresenter.new(service_type).id.should == service_type.id
  end

  it 'should respond to name' do
    ServiceTypePresenter.new(service_type).id.should == service_type.id
  end

  it 'should respond to expiration_type' do
    ServiceTypePresenter.new(service_type).expiration_type.should == 'By Date'
  end

  it 'should respond to interval_date' do
    ServiceTypePresenter.new(service_type).interval_date.should == Interval::ONE_MONTH.text
  end

  it 'should respond to interval_mileage' do
    ServiceTypePresenter.new(service_type).interval_mileage.should == '5,000'
  end

  it 'should respond to sortable_interval_mileage' do
    ServiceTypePresenter.new(service_type).sortable_interval_mileage.should == 5000
  end

  it 'should respond to sort_key' do
    ServiceTypePresenter.new(service_type).sort_key.should == 'Oil Change'
  end

  it 'should respond to interval_date_code' do
    service_type = create(:service_type, interval_date: Interval::THREE_MONTHS.text)

    ServiceTypePresenter.new(service_type).interval_date_code.should == Interval::THREE_MONTHS.id
  end
end