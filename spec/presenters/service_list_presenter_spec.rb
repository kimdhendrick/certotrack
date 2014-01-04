require 'spec_helper'

describe ServiceListPresenter do
  describe '#sort' do
    it 'should sort' do
      service = build(:service)
      fake_sorter = Faker.new([ServicePresenter.new(service)])

      presenter = ServiceListPresenter.new([service], {sorter: fake_sorter})

      presenter.sort({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == service
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end
  end

  describe '#present' do
    it 'should sort' do
      service = build(:service)
      fake_sorter = Faker.new([ServicePresenter.new(service)])

      presenter = ServiceListPresenter.new([service], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == service
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      service = build(:service)
      fake_paginator = Faker.new

      presenter = ServiceListPresenter.new([service], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == service
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of ServicePresenters' do
      service = build(:service)

      results = ServiceListPresenter.new([service]).present

      results.map(&:model).should == [service]
      results.first.should be_an_instance_of(ServicePresenter)
    end

    it 'should handle empty array' do
      presenter = ServiceListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end