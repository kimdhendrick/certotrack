require 'spec_helper'

describe ServicePeriodPresenter do
  it 'should respond to active when only service period' do
    service = create(:service)
    ServicePeriodPresenter.new(service.active_service_period).active.should == 'Active'
  end

  it 'should respond to active when not the latest service period' do
    service = create(:service, customer: create(:customer))
    historical_service_period = create(:service_period, start_date: Date.new(2010,1,1), service: service)
    ServicePeriodPresenter.new(historical_service_period).active.should == ''
  end

  it 'should respond to last_service_date' do
    service_period = create(:service_period, start_date: Date.new(2010,1,1))
    ServicePeriodPresenter.new(service_period).last_service_date.should == '01/01/2010'
  end

  it 'should respond to last_service_mileage' do
    service_period = create(:service_period, start_mileage: 1000)
    ServicePeriodPresenter.new(service_period).last_service_mileage.should == '1,000'
  end

  it 'should respond to expiration_date' do
    date_based_service_type = create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)
    date_based_service = create(:service, service_type: date_based_service_type)
    service_period = create(:service_period, end_date: Date.new(2005,12,31), service: date_based_service)

    ServicePeriodPresenter.new(service_period).expiration_date.should == '12/31/2005'
  end

  it 'should respond to expiration_mileage' do
    service_period = create(:service_period, end_mileage: 1000, service: create(:service))
    ServicePeriodPresenter.new(service_period).expiration_mileage.should == '1,000'
  end

  it 'should respond to status when not the active service period' do
    service = create(:service)
    service_period = create(:service_period, service: service)
    ServicePeriodPresenter.new(service_period).status.should == ''
  end

  it 'should respond to status when it is the active service period' do
    service_type = create(:service_type, interval_date: Interval::ONE_MONTH.text)
    service = create(:service, service_type: service_type)
    service_period = service.active_service_period
    ServicePeriodPresenter.new(service_period).status.should be_an_instance_of(Status)
  end

  it 'should respond to sort_key' do
    service_period = create(:service_period, start_date: Date.new(2001,1,1))
    ServicePeriodPresenter.new(service_period).sort_key.should == Date.new(2001,1,1)
  end
end