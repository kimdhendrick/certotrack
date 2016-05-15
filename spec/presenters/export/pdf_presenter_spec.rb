require 'spec_helper'

module Export
  describe PdfPresenter do
    describe '#present' do
      context 'any model' do
        let(:certification_collection) { [create(:certification)] }

        it 'should instantiate Prawn Document' do
          fake_prawn_document = Faker.new
          Prawn::Document.should_receive(:new).with(page_layout: :landscape).and_return(fake_prawn_document)

          PdfPresenter.new(certification_collection, '').present
        end

        it 'should create a prawn table' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new(certification_collection, 'title').present

          fake_prawn_document.received_messages[0].should == :text
          fake_prawn_document.received_messages[1].should == :table
          fake_prawn_document.received_messages[2].should == :render
        end

        it 'should render the proper title and formatting' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new(certification_collection, 'title').present

          fake_prawn_document.received_messages[0].should == :text
          fake_prawn_document.all_received_params[0].should ==
            [
              'title',
              {:size => 22, :style => :bold}
            ]
        end

        it 'should render the proper table formatting' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new(certification_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]

          formatting_options = table_params[1]
          formatting_options.should ==
            {:header => true, :row_colors => ['F0F0F0', 'FFFFCC'], :cell_style => {:size => 10}}
        end

        it 'should sort the collection' do
          fake_list_presenter = Faker.new([])
          ListPresenter.stub(:new).and_return(fake_list_presenter)

          PdfPresenter.new([Equipment.new], '', {sort: 'name', direction: 'asc'}).present

          fake_list_presenter.received_message.should == :sort
          fake_list_presenter.received_params[0][:sort].should == 'name'
          fake_list_presenter.received_params[0][:direction].should == 'asc'
        end

        it 'can present an empty collection' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new([], '').present

          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          header_row = table_header_and_data[0]

          header_row.should == ["No results found"]
        end
      end

      context 'exporting equipment' do
        let(:equipment_collection) { [create(:equipment)] }

        it 'should render the proper header row' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new(equipment_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          header_row = table_header_and_data[0]

          header_row.should ==
            ['Name', 'Serial Number', 'Status', 'Inspection Interval', 'Last Inspection Date', 'Inspection Type', 'Expiration Date', 'Assignee', 'Created By User', 'Created Date']
        end

        it 'should render the proper data' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)
          equipment_collection = [
            create(
              :equipment,
              name: 'Meter',
              serial_number: 'MySerialNum',
              created_by: 'username'
            )
          ]

          PdfPresenter.new(equipment_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          table_data = table_header_and_data[1]
          table_data.should ==
            ['Meter', 'MySerialNum', 'N/A', 'Annually', '01/01/2000', 'Inspectable', '', 'Unassigned', 'username', "#{Date.current.strftime('%m/%d/%Y')}"]
        end

        it 'should sort the collection' do
          equipment = create(:equipment)
          fake_list_presenter = Faker.new(EquipmentListPresenter.new([equipment]).present)
          EquipmentListPresenter.stub(:new).and_return(fake_list_presenter)

          PdfPresenter.new([equipment], '', {sort: 'name', direction: 'asc'}).present

          fake_list_presenter.received_message.should == :sort
          fake_list_presenter.received_params[0][:sort].should == 'name'
          fake_list_presenter.received_params[0][:direction].should == 'asc'
        end
      end
    end
  end
end