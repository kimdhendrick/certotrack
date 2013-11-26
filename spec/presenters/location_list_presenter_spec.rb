require 'spec_helper'

describe LocationListPresenter do
  describe '#sort' do
    it 'should sort' do
      location = build(:location)
      fake_sorter = Faker.new([LocationPresenter.new(location)])

      presenter = LocationListPresenter.new([location], {sorter: fake_sorter})

      presenter.sort({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == location
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end
  end
  describe '#present' do
    it 'should sort' do
      location = build(:location)
      fake_sorter = Faker.new([LocationPresenter.new(location)])

      presenter = LocationListPresenter.new([location], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == location
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      location = build(:location)
      fake_paginator = Faker.new

      presenter = LocationListPresenter.new([location], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == location
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of LocationPresenters' do
      location = build(:location)

      results = LocationListPresenter.new([location]).present

      results.map(&:model).should == [location]
      results.first.should be_an_instance_of(LocationPresenter)
    end

    it 'should handle empty array' do
      presenter = LocationListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end