require 'spec_helper'

describe EmployeeListPresenter do
  describe '#initialize' do
    it 'should wrap models in EmployeePresenters' do
      employee = build(:employee)
      fake_sorter = Faker.new()

      sut = EmployeeListPresenter.new([employee], {sorter: fake_sorter})

      sut.collection.map(&:model).should == [employee]
    end
  end

  describe '#present' do
    it 'should sort' do
      employee = build(:employee)
      fake_sorter = Faker.new([EmployeePresenter.new(employee)])

      sut = EmployeeListPresenter.new([employee], {sorter: fake_sorter})

      sut.present

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == employee
    end

    it 'should paginate' do
      employee = build(:employee)
      fake_paginator = Faker.new()

      sut = EmployeeListPresenter.new([employee], {paginator: fake_paginator})

      sut.present

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == employee
    end
  end
end