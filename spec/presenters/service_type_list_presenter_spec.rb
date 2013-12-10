require 'spec_helper'

describe ServiceTypeListPresenter do
  describe '#present' do
    it 'should sort' do
      service_type = build(:service_type)
      fake_sorter = Faker.new([ServiceTypePresenter.new(service_type)])

      presenter = ServiceTypeListPresenter.new([service_type], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == service_type
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      service_type = build(:service_type)
      fake_paginator = Faker.new

      presenter = ServiceTypeListPresenter.new([service_type], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == service_type
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of ServiceTypePresenters' do
      service_type = build(:service_type)

      results = ServiceTypeListPresenter.new([service_type]).present

      results.map(&:model).should == [service_type]
      results.first.should be_an_instance_of(ServiceTypePresenter)
    end

    it 'should handle empty array' do
      presenter = ServiceTypeListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end