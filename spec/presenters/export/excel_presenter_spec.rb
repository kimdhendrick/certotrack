require 'spec_helper'

module Export
  describe ExcelPresenter do
    describe '#present' do
      before do
        exporter_factory = double(:exporter_factory)
        allow(ExporterFactory).to receive(:new).and_return(exporter_factory)
        allow(exporter_factory).to receive(:instance).and_return(exporter)
      end

      let(:collection) { Faker.new([]) }
      let(:exporter) { double(:exporter, collection: collection, headers: headers, column_names: column_names) }
      let(:headers) { ['excel headers'] }
      let(:column_names) { ['column_names'] }

      it 'should call to_xls' do
        ExcelPresenter.new([], '').present

        collection.received_messages[0].should == :to_xls
      end

      context 'exporting' do
        before do
          ExcelPresenter.new([Equipment.new], 'Equipment Sheet Title').present
        end

        it 'should call to_xls with the right headers' do
          collection.received_params[0][:headers].should == headers
        end

        it 'should call to_xls with the right columns' do
          collection.received_params[0][:columns].should == column_names
        end

        it 'should call to_xls with the sheet name' do
          collection.received_params[0][:name].should == 'Equipment Sheet Title'
        end
      end
    end
  end
end