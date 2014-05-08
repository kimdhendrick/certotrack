require 'spec_helper'

describe ServiceTypePresenter do

  let(:service_type) do
    build(:service_type,
          name: 'Oil Change',
          expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
          interval_date: Interval::THREE_MONTHS.text,
          interval_mileage: 5000,
          customer: create(:customer, name: 'myCustomer'))
  end

  subject { ServiceTypePresenter.new(service_type) }

  it 'should respond to model' do
    subject.model.should == service_type
  end

  it 'should respond to id' do
    subject.id.should == service_type.id
  end

  it 'should respond to name' do
    subject.id.should == service_type.id
  end

  it 'should respond to expiration_type' do
    subject.expiration_type.should == 'By Date'
  end

  it 'should respond to interval_date' do
    subject.interval_date.should == Interval::THREE_MONTHS.text
  end

  it 'should respond to interval_mileage' do
    subject.interval_mileage.should == '5,000'
  end

  it 'should respond to sortable_interval_mileage' do
    subject.sortable_interval_mileage.should == 5000
  end

  it 'should respond to sort_key' do
    subject.sort_key.should == 'Oil Change'
  end

  it 'should respond to interval_date_code' do
    subject.interval_date_code.should == Interval::THREE_MONTHS.id
  end

  it 'should respond to expiration_type_of_date?' do
    date_service_type = ServiceTypePresenter.new(create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE))
    date_and_mileage_service_type = ServiceTypePresenter.new(create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE))
    mileage_service_type = ServiceTypePresenter.new(create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE))

    date_service_type.date_expiration_type?.should be_true
    date_and_mileage_service_type.date_expiration_type?.should be_true
    mileage_service_type.date_expiration_type?.should be_false
  end

  it 'should respond to expiration_type_of_mileage?' do
    mileage_service_type = ServiceTypePresenter.new(create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE))
    date_and_mileage_service_type = ServiceTypePresenter.new(create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE))
    date_service_type = ServiceTypePresenter.new(create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE))

    date_and_mileage_service_type.mileage_expiration_type?.should be_true
    mileage_service_type.mileage_expiration_type?.should be_true
    date_service_type.mileage_expiration_type?.should be_false
  end

  describe 'edit_link' do
    it 'should create a link to the edit page' do
      service_type = create(:service_type)
      subject = ServiceTypePresenter.new(service_type, view)
      subject.edit_link.should =~ /<a.*>Edit<\/a>/
    end
  end

  describe 'delete_link' do
    it 'should create a link to the delete page' do
      service_type = build(:service_type)
      subject = ServiceTypePresenter.new(service_type, view)
      subject.delete_link.should =~ /<a.*>Delete<\/a>/
    end
  end
end