require 'spec_helper'

describe ServicePresenter do
  include ActionView::TestCase::Behavior

  let(:service) do
    service_type = create(:service_type,
                          name: 'Oil Change',
                          expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE,
                          interval_date: Interval::ONE_MONTH.text,
                          interval_mileage: 5000,
                          customer: create(:customer, name: 'myCustomer'))

    vehicle = create(:vehicle,
                     make: 'Ford',
                     vehicle_model: 'Edge',
                     year: 2009,
                     mileage: 10000,
                     vehicle_number: '123123',
                     vin: '12312312312312312',
                     location: create(:location, name: 'Golden'),
                     license_plate: 'GLI',
                     customer: service_type.customer)

    build(:service,
          service_type: service_type,
          vehicle: vehicle,
          last_service_date: Date.new(2000, 1, 1),
          last_service_mileage: 7000,
          expiration_date: Date.new(2000, 6, 1),
          expiration_mileage: 10000,
          comments: 'comments',
          customer: service_type.customer)
  end

  subject { ServicePresenter.new(service) }

  it_behaves_like 'an object that is sortable by status'

  it 'should respond to model' do
    subject.model.should == service
  end

  it 'should respond to id' do
    subject.id.should == service.id
  end

  it 'should respond to service_type_name' do
    subject.service_type_name.should == 'Oil Change'
  end

  it 'should respond to service_due_date' do
    subject.service_due_date.should == '06/01/2000'
  end

  it 'should respond to service_due_mileage' do
    subject.service_due_mileage.should == '10,000'
  end

  it 'should respond to last_service_date' do
    subject.last_service_date.should == '01/01/2000'
  end

  it 'should respond to last_service_mileage' do
    subject.last_service_mileage.should == '7,000'
  end

  it 'should respond to sortable_service_due_date' do
    subject.sortable_service_due_date.should == Date.new(2000, 6, 1)
  end

  it 'should respond to sortable_service_due_mileage' do
    subject.sortable_service_due_mileage.should == 10000
  end

  it 'should respond to sortable_last_service_date' do
    subject.sortable_last_service_date.should == Date.new(2000, 1, 1)
  end

  it 'should respond to sortable_last_service_mileage' do
    subject.sortable_last_service_mileage.should == 7000
  end

  it 'should respond to sort_key' do
    subject.sort_key.should == 'Oil Change'
  end

  it 'should respond to vehicle_number' do
    subject.vehicle_number.should == '123123'
  end

  it 'should respond to vehicle_vin' do
    subject.vehicle_vin.should == '12312312312312312'
  end

  it 'should respond to vehicle_license_plate' do
    subject.vehicle_license_plate.should == 'GLI'
  end

  it 'should respond to vehicle_year' do
    subject.vehicle_year.should == 2009
  end

  it 'should respond to vehicle_make' do
    subject.vehicle_make.should == 'Ford'
  end

  it 'should respond to vehicle_model' do
    subject.vehicle_model.should == 'Edge'
  end

  it 'should respond to vehicle mileage' do
    subject.vehicle_mileage.should == '10,000'
  end

  it 'should respond to sortable_vehicle_mileage' do
    subject.sortable_vehicle_mileage.should == 10000
  end

  it 'should respond to location' do
    subject.vehicle_location.should == 'Golden'
  end

  it 'should respond to comments' do
    subject.comments.should == 'comments'
  end

  it 'should respond to expiration_type_of_date?' do
    date_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)))
    date_and_mileage_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE)))
    mileage_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE)))

    date_service.date_expiration_type?.should be_true
    date_and_mileage_service.date_expiration_type?.should be_true
    mileage_service.date_expiration_type?.should be_false
  end

  it 'should respond to expiration_type_of_mileage?' do
    mileage_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE)))
    date_and_mileage_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE)))
    date_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)))

    date_and_mileage_service.mileage_expiration_type?.should be_true
    mileage_service.mileage_expiration_type?.should be_true
    date_service.mileage_expiration_type?.should be_false
  end

  it 'should respond to expiration_type' do
    mileage_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE)))
    date_and_mileage_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE)))
    date_service = ServicePresenter.new(create(:service, service_type: create(:service_type, expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE)))

    date_and_mileage_service.expiration_type.should == 'By Date and Mileage'
    mileage_service.expiration_type.should == 'By Mileage'
    date_service.expiration_type.should == 'By Date'
  end

  it 'should respond to interval_date' do
    subject.interval_date.should == '1 month'
  end

  it 'should respond to interval_mileage' do
    subject.interval_mileage.should == '5,000'
  end

  describe '#reservice_link' do
    it 'should return a valid reservice link' do
      service = create(:service)

      service_presenter = ServicePresenter.new(service, view)

      service_presenter.reservice_link.should =~ /<a.*>Reservice<\/a>/
    end
  end

  describe '#edit_link' do
    it 'should return a valid edit link' do
      service = create(:service)
      service_presenter = ServicePresenter.new(service, view)
      service_presenter.edit_link.should =~ /<a.*>Edit<\/a>/
    end
  end

  describe '#delete_link' do
    it 'should return a valid delete link' do
      service = build(:service)
      service_presenter = ServicePresenter.new(service, view)
      service_presenter.delete_link.should =~ /<a.*>Delete<\/a>/
    end
  end

  describe '#show_history_link' do
    it 'should return a valid show_history link' do
      service = create(:service)
      service_presenter = ServicePresenter.new(service, view)
      service_presenter.show_history_link.should =~ /<a.*>Service History<\/a>/
    end
  end

  describe '#show_link' do
    it 'should return a valid show link' do
      service = create(:service)
      service_presenter = ServicePresenter.new(service, view)
      service_presenter.show_link.should =~ /<a.*>Back to service<\/a>/
    end
  end
end