require 'spec_helper'

describe ServicePeriodListPresenter do
  describe '#present' do
    it 'should sort descending' do
      service_period = build(:service_period)
      fake_sorter = Faker.new([ServicePeriodPresenter.new(service_period)])

      presenter = ServicePeriodListPresenter.new([service_period], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == service_period
      fake_sorter.received_params[1].should == :sort_key
      fake_sorter.received_params[2].should == 'desc'
    end

    it 'should return a collection of ServicePeriodPresenters' do
      service_period = build(:service_period)

      results = ServicePeriodListPresenter.new([service_period]).present

      results.map(&:model).should == [service_period]
      results.first.should be_an_instance_of(ServicePeriodPresenter)
    end

    it 'should handle empty array' do
      presenter = ServicePeriodListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end