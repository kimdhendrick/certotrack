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

          PdfPresenter.new([], '', {sort: 'name', direction: 'asc'}).present

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

      context 'exporting certifications' do
        let(:certification_collection) { [create(:certification)] }

        it 'should render the proper header row' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new(certification_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          header_row = table_header_and_data[0]

          header_row.should ==
            ['Employee', 'Certification Type', 'Status', 'Units Achieved', 'Last Certification Date', 'Expiration Date', 'Trainer', 'Created By User', 'Created Date', 'Comments']
        end

        it 'should render the proper data' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)
          employee = create(
            :employee,
            first_name: 'Joe',
            last_name: 'Brown'
          )
          certification_type = create(:certification_type, units_required: 10, name: 'CPR')
          certification_collection = [
            create(
              :certification,
              employee: employee,
              certification_type: certification_type,
              units_achieved: 12,
              last_certification_date: Date.new(2013, 1, 2),
              expiration_date: Date.new(2014, 1, 2),
              trainer: 'Trainer Tom',
              created_by: 'username',
              comments: 'Well done'
            )
          ]

          PdfPresenter.new(certification_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          table_data = table_header_and_data[1]
          table_data.should ==
            ['Brown, Joe', 'CPR', 'Valid', '12', '01/02/2013', '01/02/2014', 'Trainer Tom', 'username', "#{Date.current.strftime('%m/%d/%Y')}", 'Well done']
        end

        it 'should sort the collection of certifications' do
          certification = create(:certification)
          fake_list_presenter = Faker.new(CertificationListPresenter.new([certification]).present)
          CertificationListPresenter.stub(:new).and_return(fake_list_presenter)

          PdfPresenter.new([certification], '', {sort: 'name', direction: 'asc'}).present

          fake_list_presenter.received_message.should == :sort
          fake_list_presenter.received_params[0][:sort].should == 'name'
          fake_list_presenter.received_params[0][:direction].should == 'asc'
        end
      end

      context 'exporting employees' do
        let(:employee_collection) { [create(:employee)] }

        it 'should render the proper header row' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new(employee_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          header_row = table_header_and_data[0]

          header_row.should ==
            ['Employee Number', 'First Name', 'Last Name', 'Location', 'Created By User', 'Created Date']
        end

        it 'should render the proper data' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)
          employee_collection = [
            create(
              :employee,
              employee_number: 'JB888',
              first_name: 'Joe',
              last_name: 'Brown',
              location: create(:location, name: 'Denver'),
              created_by: 'Me'
            )
          ]

          PdfPresenter.new(employee_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          table_data = table_header_and_data[1]
          table_data.should ==
            ['JB888', 'Joe', 'Brown', 'Denver', 'Me', "#{Date.current.strftime('%m/%d/%Y')}"]
        end
      end

      context 'exporting customers' do
        let(:customer_collection) { [create(:customer)] }

        it 'should render the proper header row' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new(customer_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          header_row = table_header_and_data[0]

          header_row.should ==
            ['Name', 'Account Number', 'Contact Person Name', 'Contact Email', 'Contact Phone Number', 'Address 1', 'Address 2', 'City', 'State', 'Zip', 'Active', 'Equipment Access', 'Certification Access', 'Vehicle Access', 'Created Date']
        end

        it 'should render the proper data' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)
          customer_collection = [
            create(
              :customer,
              name: 'City Of Something',
              contact_person_name: 'Someone Special',
              contact_phone_number: '303-222-4232',
              contact_email: 'email@address.com',
              account_number: 'ACTNUM111',
              address1: '100 Main St',
              address2: 'Suite 100',
              city: 'Boston',
              state: 'MA',
              zip: '12333',
              active: true,
              equipment_access: true,
              certification_access: true,
              vehicle_access: true
            )
          ]

          PdfPresenter.new(customer_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          table_data = table_header_and_data[1]
          table_data.should ==
            ['City Of Something', 'ACTNUM111', 'Someone Special', 'email@address.com', '303-222-4232',
             '100 Main St', 'Suite 100', 'Boston', 'MA', '12333', 'Yes', 'Yes', 'Yes', 'Yes', "#{Date.current.strftime('%m/%d/%Y')}"]
        end
      end

      context 'exporting users' do
        let(:user_collection) { [create(:user)] }

        it 'should render the proper header row' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)

          PdfPresenter.new(user_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          header_row = table_header_and_data[0]

          header_row.should ==
            ['Username', 'First Name', 'Last Name', 'Email Address', 'Password Last Changed', 'Notification Interval', 'Customer', 'Created Date']
        end

        it 'should render the proper data' do
          fake_prawn_document = Faker.new
          Prawn::Document.stub(:new).and_return(fake_prawn_document)
          user_collection = [
            create(
              :user,
              username: 'username123',
              first_name: 'Joe',
              last_name: 'Smith',
              email: 'jsmith@example.com',
              customer: create(:customer, name: 'My Customer'),
              password_changed_at: Date.new(2010, 1, 1),
              expiration_notification_interval: 'Never'
            )
          ]

          PdfPresenter.new(user_collection, 'title').present

          fake_prawn_document.received_messages[1].should == :table
          table_params = fake_prawn_document.all_received_params[1]
          table_header_and_data = table_params[0]
          table_data = table_header_and_data[1]
          table_data.should ==
            ['username123', 'Joe', 'Smith', 'jsmith@example.com', '01/01/2010', 'Never', 'My Customer', "#{Date.current.strftime('%m/%d/%Y')}"]
        end
      end
    end
  end
end