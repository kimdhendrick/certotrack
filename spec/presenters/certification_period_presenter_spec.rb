require 'spec_helper'

describe CertificationPeriodPresenter do
  it 'should respond to active when only certification period' do
    certification = create(:certification)
    CertificationPeriodPresenter.new(certification.active_certification_period).active.should == 'Active'
  end

  it 'should respond to active when not the latest certification period' do
    certification = create(:certification, customer: create(:customer))
    historical_certification_period = create(:certification_period, start_date: Date.new(2010,1,1), certification: certification)
    CertificationPeriodPresenter.new(historical_certification_period).active.should == ''
  end

  it 'should respond to last_certification_date' do
    certification_period = create(:certification_period, start_date: Date.new(2010,1,1))
    CertificationPeriodPresenter.new(certification_period).last_certification_date.should == '01/01/2010'
  end

  it 'should respond to expiration_inspection_date' do
    certification_period = create(:certification_period, end_date: Date.new(2005,12,31))
    CertificationPeriodPresenter.new(certification_period).expiration_date.should == '12/31/2005'
  end

  it 'should respond to units when units_based' do
    certification_type = create(:certification_type, units_required: 30)
    certification_period = create(:certification_period, units_achieved: 15)
    create(:certification, certification_type: certification_type, active_certification_period: certification_period)
    CertificationPeriodPresenter.new(certification_period).units.should == '15 of 30'
  end

  it 'should respond to units when date_based' do
    certification_type = create(:certification_type, units_required: 0)
    certification = create(:certification, certification_type: certification_type)
    CertificationPeriodPresenter.new(certification.active_certification_period).units.should == ''
  end

  it 'should respond to trainer' do
    certification_period = create(:certification_period, trainer: 'Joey')
    CertificationPeriodPresenter.new(certification_period).trainer.should == 'Joey'
  end

  it 'should respond to status when not the active certification period' do
    certification = create(:certification)
    certification_period = create(:certification_period, certification: certification)
    CertificationPeriodPresenter.new(certification_period).status.should == ''
  end

  it 'should respond to status when it is the active certification period' do
    certification_type = create(:certification_type, interval: Interval::ONE_MONTH.text)
    certification = create(:certification, certification_type: certification_type)
    certification_period = certification.active_certification_period
    CertificationPeriodPresenter.new(certification_period).status.should be_an_instance_of(Status)
  end

  it 'should respond to sort_key' do
    certification_period = create(:certification_period, start_date: Date.new(2001,1,1))
    CertificationPeriodPresenter.new(certification_period).sort_key.should == Date.new(2001,1,1)
  end
end