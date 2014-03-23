require 'spec_helper'

describe ExcelPresenter do
  describe '#present' do

    before do
      ExcelPresenter.any_instance.stub(:collection_wrapped_in_presenters).and_return(collection)
    end
    
    let(:collection) { Faker.new([]) }

    it 'should call to_xls' do
      ExcelPresenter.new([], '').present

      collection.received_messages[0].should == :to_xls
    end

    context 'exporting equipment' do
      before do
        ExcelPresenter.new([create(:equipment)], 'Equipment Sheet Title').present
      end

      it 'should call to_xls with the right headers' do
        headers = 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created Date,Created By User'.split(',')
        collection.received_params[0][:headers].should == headers
      end

      it 'should call to_xls with the right columns' do
        columns = [:name, :serial_number, :status_text, :inspection_interval, :last_inspection_date, :inspection_type, :expiration_date, :assignee, :created_at, :created_by]
        collection.received_params[0][:columns].should == columns
      end

      it 'should call to_xls with the sheet name' do
        collection.received_params[0][:name].should == 'Equipment Sheet Title'
      end
    end
    
    context 'exporting certifications' do
      before do
        ExcelPresenter.new([create(:certification)], 'Certification Sheet Title').present
      end

      it 'should call to_xls with the right headers' do
        headers = 'Employee,Certification Type,Status,Units Achieved,Last Certification Date,Expiration Date,Trainer,Created By User,Created Date,Comments'.split(',')
        collection.received_params[0][:headers].should == headers
      end

      it 'should call to_xls with the right columns' do
        columns = [:employee_name, :certification_type, :status_text, :units, :last_certification_date, :expiration_date, :trainer, :created_by, :created_at, :comments]
        collection.received_params[0][:columns].should == columns
      end

      it 'should call to_xls with the sheet name' do
        collection.received_params[0][:name].should == 'Certification Sheet Title'
      end
    end
  end
end