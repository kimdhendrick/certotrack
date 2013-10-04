require 'spec_helper'

describe EquipmentListPresenter do
  describe '#present' do
    it 'should sort' do
      equipment = build(:equipment)
      fake_sorter = Faker.new([EquipmentPresenter.new(equipment)])

      presenter = EquipmentListPresenter.new([equipment], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == equipment
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      equipment = build(:equipment)
      fake_paginator = Faker.new

      presenter = EquipmentListPresenter.new([equipment], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == equipment
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of EquipmentPresenters' do
      equipment = build(:equipment)

      results = EquipmentListPresenter.new([equipment]).present

      results.map(&:model).should == [equipment]
      results.first.should be_an_instance_of(EquipmentPresenter)
    end

    it 'should handle empty array' do
      presenter = EquipmentListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end