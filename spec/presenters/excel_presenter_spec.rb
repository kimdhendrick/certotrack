require 'spec_helper'

describe ExcelPresenter do
  describe '#present' do
    context 'exporting equipment' do
      before do
        ExcelPresenter.new(equipment_collection, 'Equipment Sheet Title').present
      end

      let(:equipment_collection) { Faker.new([create(:equipment)]) }

      it 'should call to_xls' do
        equipment_collection.received_messages[0].should == :empty?
        equipment_collection.received_messages[1].should == :to_xls
      end

      it 'should call to_xls with the right headers' do
        headers = 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created Date,Created By User'.split(',')
        equipment_collection.received_params[0][:headers].should == headers
      end

      it 'should call to_xls with the right columns' do
        columns = [:name, :serial_number, :status_text, :inspection_interval, :last_inspection_date, :inspection_type, :expiration_date, :assignee, :created_at, :created_by]
        equipment_collection.received_params[0][:columns].should == columns
      end

      it 'should call to_xls with the sheet name' do
        equipment_collection.received_params[0][:name].should == 'Equipment Sheet Title'
      end
    end
  end
end