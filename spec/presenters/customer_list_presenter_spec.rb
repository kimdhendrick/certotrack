require 'spec_helper'

describe CustomerListPresenter do
  describe '#sort' do
    it 'should sort' do
      customer = build(:customer)
      fake_sorter = Faker.new([CustomerPresenter.new(customer)])

      presenter = CustomerListPresenter.new([customer], {sorter: fake_sorter})

      presenter.sort({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == customer
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end
  end
  describe '#present' do
    it 'should sort' do
      customer = build(:customer)
      fake_sorter = Faker.new([CustomerPresenter.new(customer)])

      presenter = CustomerListPresenter.new([customer], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == customer
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      customer = build(:customer)
      fake_paginator = Faker.new

      presenter = CustomerListPresenter.new([customer], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == customer
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of CustomerPresenters' do
      customer = build(:customer)

      results = CustomerListPresenter.new([customer]).present

      results.map(&:model).should == [customer]
      results.first.should be_an_instance_of(CustomerPresenter)
    end

    it 'should handle empty array' do
      presenter = CustomerListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end