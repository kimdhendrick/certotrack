require 'spec_helper'

describe CertificationTypeListPresenter do
  describe '#sort' do
    it 'should sort' do
      certification_type = build(:certification_type)
      fake_sorter = Faker.new([CertificationTypePresenter.new(certification_type)])

      presenter = CertificationTypeListPresenter.new([certification_type], {sorter: fake_sorter})

      presenter.sort({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == certification_type
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end
  end

  describe '#present' do
    it 'should sort' do
      certification_type = build(:certification_type)
      fake_sorter = Faker.new([CertificationTypePresenter.new(certification_type)])

      presenter = CertificationTypeListPresenter.new([certification_type], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == certification_type
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      certification_type = build(:certification_type)
      fake_paginator = Faker.new

      presenter = CertificationTypeListPresenter.new([certification_type], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == certification_type
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of CertificationTypePresenters' do
      certification_type = build(:certification_type)

      results = CertificationTypeListPresenter.new([certification_type]).present

      results.map(&:model).should == [certification_type]
      results.first.should be_an_instance_of(CertificationTypePresenter)
    end

    it 'should handle empty array' do
      presenter = CertificationTypeListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end