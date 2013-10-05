require 'spec_helper'

describe CertificationListPresenter do
  describe '#present' do
    it 'should sort' do
      certification = build(:certification)
      fake_sorter = Faker.new([CertificationPresenter.new(certification)])

      presenter = CertificationListPresenter.new([certification], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == certification
      fake_sorter.received_params[1].should == :field
      fake_sorter.received_params[2].should == :asc
    end

    it 'should paginate' do
      certification = build(:certification)
      fake_paginator = Faker.new

      presenter = CertificationListPresenter.new([certification], {paginator: fake_paginator})

      presenter.present(page: 100)

      fake_paginator.received_message.should == :paginate
      fake_paginator.received_params[0][0].model.should == certification
      fake_paginator.received_params[1].should == 100
    end

    it 'should return a collection of CertificationPresenters' do
      certification = build(:certification)

      results = CertificationListPresenter.new([certification]).present

      results.map(&:model).should == [certification]
      results.first.should be_an_instance_of(CertificationPresenter)
    end

    it 'should handle empty array' do
      presenter = CertificationListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end