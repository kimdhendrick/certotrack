require 'spec_helper'

describe CsvPresenter do
  describe '#present' do
    context 'exporting equipment' do
      before do
        create(
          :equipment,
          name: 'Box',
          serial_number: 'MySerialNumber',
          last_inspection_date: Date.new(2013, 12, 15),
          expiration_date: Date.new(2016, 12, 20),
          inspection_interval: 'Annually'
        )
      end

      it 'can present an empty collection' do
        CsvPresenter.new([]).present.should == "Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created Date\n"
      end

      it 'should have the right equipment headers' do
        results = CsvPresenter.new(Equipment.all).present

        results.split("\n")[0].should == 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created Date'
      end

      it 'should have the right data' do
        Equipment.count.should == 1

        results = CsvPresenter.new(Equipment.all).present

        data_results = results.split("\n")[1].split(',')

        data_results[0].should == 'Box'
        data_results[1].should == 'MySerialNumber'
        data_results[2].should == 'Valid'
        data_results[3].should == 'Annually'
        data_results[4].should == '12/15/2013'
        data_results[5].should == 'Inspectable'
        data_results[6].should == '12/20/2016'
        data_results[7].should == 'Unassigned'
        data_results[8].should == "#{Date.current.strftime("%m/%d/%Y")}"
      end
    end
  end
end