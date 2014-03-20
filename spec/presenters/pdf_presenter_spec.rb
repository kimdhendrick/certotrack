require 'spec_helper'

describe PdfPresenter do
  describe '#present' do
    context 'exporting equipment' do
      let(:equipment_collection) { [create(:equipment)] }

      it 'should instantiate Prawn Document' do
        fake_prawn_document = Faker.new
        Prawn::Document.should_receive(:new).with(page_layout: :landscape).and_return(fake_prawn_document)

        PdfPresenter.new(equipment_collection, '').present
      end

      it 'should create a prawn table' do
        fake_prawn_document = Faker.new
        Prawn::Document.stub(:new).and_return(fake_prawn_document)

        PdfPresenter.new(equipment_collection, 'title').present

        fake_prawn_document.received_messages[0].should == :text
        fake_prawn_document.received_messages[1].should == :table
        fake_prawn_document.received_messages[2].should == :render
      end

      it 'should render the proper title and formatting' do
        fake_prawn_document = Faker.new
        Prawn::Document.stub(:new).and_return(fake_prawn_document)

        PdfPresenter.new(equipment_collection, 'title').present

        fake_prawn_document.received_messages[0].should == :text
        fake_prawn_document.all_received_params[0].should ==
          [
            'title',
            {:size => 22, :style => :bold}
          ]
      end

      it 'should render the proper data' do
        fake_prawn_document = Faker.new
        Prawn::Document.stub(:new).and_return(fake_prawn_document)
        equipment_collection = [
          create(
            :equipment,
            name: 'Meter',
            serial_number: 'MySerialNum'
          )
        ]

        PdfPresenter.new(equipment_collection, 'title').present

        fake_prawn_document.received_messages[1].should == :table
        table_params = fake_prawn_document.all_received_params[1]
        table_header_and_data = table_params[0]
        table_data = table_header_and_data[1]
        table_data.should ==
          ['Meter', 'MySerialNum', 'N/A', 'Annually', '01/01/2000', 'Inspectable', '', 'Unassigned', "#{Date.current.strftime("%m/%d/%Y")}"]
      end

      it 'should render the proper header row' do
        fake_prawn_document = Faker.new
        Prawn::Document.stub(:new).and_return(fake_prawn_document)

        PdfPresenter.new(equipment_collection, 'title').present

        fake_prawn_document.received_messages[1].should == :table
        table_params = fake_prawn_document.all_received_params[1]
        table_header_and_data = table_params[0]
        header_row = table_header_and_data[0]

        header_row.should ==
          ['Name', 'Serial Number', 'Status', 'Inspection Interval', 'Last Inspection Date', 'Inspection Type', 'Expiration Date', 'Assignee', 'Created Date']
      end

      it 'should render the proper table formatting' do
        fake_prawn_document = Faker.new
        Prawn::Document.stub(:new).and_return(fake_prawn_document)

        PdfPresenter.new(equipment_collection, 'title').present

        fake_prawn_document.received_messages[1].should == :table
        table_params = fake_prawn_document.all_received_params[1]

        formatting_options = table_params[1]
        formatting_options.should ==
          {:header => true, :row_colors => ['F0F0F0', 'FFFFCC'], :cell_style => {:size => 10}}
      end

      it 'should sort the collection' do
        fake_list_presenter = Faker.new([])
        EquipmentListPresenter.stub(:new).and_return(fake_list_presenter)

        PdfPresenter.new([], '', {sort: 'name', direction: 'asc'}).present

        fake_list_presenter.received_message.should == :sort
        fake_list_presenter.received_params[0][:sort].should == 'name'
        fake_list_presenter.received_params[0][:direction].should == 'asc'
      end
    end
  end
end