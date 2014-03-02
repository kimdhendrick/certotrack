require 'spec_helper'

describe UserListPresenter do
  describe '#sort' do
    it 'should sort' do
      user = build(:user)
      fake_sorter = Faker.new([UserPresenter.new(user)])

      presenter = UserListPresenter.new([user], {sorter: fake_sorter})

      presenter.sort({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == user
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end
  end

  describe '#present' do
    it 'should sort' do
      user = build(:user)
      fake_sorter = Faker.new([UserPresenter.new(user)])

      presenter = UserListPresenter.new([user], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == user
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      user = build(:user)
      fake_paginator = Faker.new

      presenter = UserListPresenter.new([user], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == user
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of UserPresenters' do
      user = build(:user)

      results = UserListPresenter.new([user]).present

      results.map(&:model).should == [user]
      results.first.should be_an_instance_of(UserPresenter)
    end

    it 'should handle empty array' do
      presenter = UserListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end