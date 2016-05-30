require 'spec_helper'

module Export
  describe ExcelPresenter do
    describe '#present' do
      let(:collection) { Faker.new([]) }
      let(:exporter) { double(:exporter, collection: collection, headers: headers, column_names: column_names) }
      let(:headers) { ['excel headers'] }
      let(:column_names) { ['column_names'] }
      let(:equipment_collection) { [Equipment.new] }

      before do
        exporter_factory = double(:exporter_factory)
        allow(ExporterFactory).to receive(:new).and_return(exporter_factory)
        allow(exporter_factory).to receive(:instance).and_return(exporter)
      end

      it 'should call to_xls' do
        described_class.new([], '').present

        collection.received_messages[0].should == :to_xls
      end

      it 'should call to_xls with the right headers' do
        described_class.new(equipment_collection, 'Equipment Sheet Title').present

        collection.received_params[0][:headers].should == headers
      end

      it 'should call to_xls with the right columns' do
        described_class.new(equipment_collection, 'Equipment Sheet Title').present

        collection.received_params[0][:columns].should == column_names
      end

      it 'should call to_xls with the sheet name' do
        described_class.new(equipment_collection, 'Equipment Sheet Title').present

        collection.received_params[0][:name].should == 'Equipment Sheet Title'
      end
    end
  end
end