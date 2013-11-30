require 'spec_helper'

describe VehicleListPresenter do
  describe '#present' do
    it 'should sort' do
      vehicle = build(:vehicle)
      fake_sorter = Faker.new([VehiclePresenter.new(vehicle)])

      presenter = VehicleListPresenter.new([vehicle], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == vehicle
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      vehicle = build(:vehicle)
      fake_paginator = Faker.new

      presenter = VehicleListPresenter.new([vehicle], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == vehicle
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of VehiclePresenters' do
      vehicle = build(:vehicle)

      results = VehicleListPresenter.new([vehicle]).present

      results.map(&:model).should == [vehicle]
      results.first.should be_an_instance_of(VehiclePresenter)
    end

    it 'should handle empty array' do
      presenter = VehicleListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end