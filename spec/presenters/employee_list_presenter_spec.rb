require 'spec_helper'

describe EmployeeListPresenter do
  describe '#sort' do
    it 'should sort' do
      employee = build(:employee)
      fake_sorter = Faker.new([EmployeePresenter.new(employee)])

      presenter = EmployeeListPresenter.new([employee], {sorter: fake_sorter})

      presenter.sort({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == employee
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end
  end

  describe '#present' do
    it 'should sort' do
      employee = build(:employee)
      fake_sorter = Faker.new([EmployeePresenter.new(employee)])

      presenter = EmployeeListPresenter.new([employee], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == employee
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      employee = build(:employee)
      fake_paginator = Faker.new

      presenter = EmployeeListPresenter.new([employee], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == employee
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of EmployeePresenters' do
      employee = build(:employee)

      results = EmployeeListPresenter.new([employee]).present

      results.map(&:model).should == [employee]
      results.first.should be_an_instance_of(EmployeePresenter)
    end

    it 'should handle empty array' do
      presenter = EmployeeListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end