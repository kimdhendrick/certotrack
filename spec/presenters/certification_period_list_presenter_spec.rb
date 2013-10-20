require 'spec_helper'

describe CertificationPeriodListPresenter do
  describe '#present' do
    it 'should sort descending' do
      certification_period = build(:certification_period)
      fake_sorter = Faker.new([CertificationPeriodPresenter.new(certification_period)])

      presenter = CertificationPeriodListPresenter.new([certification_period], {sorter: fake_sorter})

      presenter.present({sort: :field, direction: :asc})

      fake_sorter.received_message.should == :sort
      fake_sorter.received_params[0][0].model.should == certification_period
      fake_sorter.received_params[1].should == :sort_key
      fake_sorter.received_params[2].should == 'desc'
    end

    it 'should return a collection of CertificationPeriodPresenters' do
      certification_period = build(:certification_period)

      results = CertificationPeriodListPresenter.new([certification_period]).present

      results.map(&:model).should == [certification_period]
      results.first.should be_an_instance_of(CertificationPeriodPresenter)
    end

    it 'should handle empty array' do
      presenter = CertificationPeriodListPresenter.new([])

      presenter.present.count.should == 0
    end
  end
end