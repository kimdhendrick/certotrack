require 'spec_helper'

module Export
  describe CollectionExporter do
    let(:equipment) { Equipment.new }
    let(:equipment_collection) { [equipment] }
    let(:collection_wrapper) { double(:collection_wrapper, collection: []) }

    describe '#headers' do
      context 'when equipment' do
        let(:collection) { [equipment] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created By User,Created Date'.split(',')
        end
      end

      context 'when user' do
        let(:collection) { [User.new] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq 'Username,First Name,Last Name,Email Address,Password Last Changed,Notification Interval,Customer,Created Date'.split(',')
        end
      end

      context 'when certification' do
        let(:collection) { [Certification.new] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq 'Employee,Employee Number,Employee Location,Certification Type,Status,Units Achieved,Last Certification Date,Expiration Date,Trainer,Created By User,Created Date,Comments'.split(',')
        end
      end

      context 'when customer' do
        let(:collection) { [Customer.new] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq 'Name,Account Number,Contact Person Name,Contact Email,Contact Phone Number,Address 1,Address 2,City,State,Zip,Active,Equipment Access,Certification Access,Vehicle Access,Created Date'.split(',')
        end
      end

      context 'when employee' do
        let(:collection) { [Employee.new] }

        it 'should return the right headers' do
          result = described_class.new(collection, collection_wrapper).headers

          expect(result).to eq 'Employee Number,First Name,Last Name,Location,Created By User,Created Date'.split(',')
        end
      end
    end

    describe '#column_names' do
      context 'when equipment' do
        let(:collection) { [equipment] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq [:name, :serial_number, :status_text, :inspection_interval, :last_inspection_date, :inspection_type, :expiration_date, :assignee, :created_by, :created_at]
        end
      end

      context 'when user' do
        let(:collection) { [User.new] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq [:username, :first_name, :last_name, :email, :password_changed_at, :expiration_notification_interval, :customer_name, :created_at]
        end
      end

      context 'when certification' do
        let(:collection) { [Certification.new] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq [:employee_name, :employee_number, :location_name, :certification_type, :status_text, :units, :last_certification_date, :expiration_date, :trainer, :created_by, :created_at, :comments]
        end
      end

      context 'when customer' do
        let(:collection) { [Customer.new] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq [:name, :account_number, :contact_person_name, :contact_email, :contact_phone_number, :address1, :address2, :city, :state, :zip, :active, :equipment_access, :certification_access, :vehicle_access, :created_at]
        end
      end

      context 'when employee' do
        let(:collection) { [Employee.new] }

        it 'should return the right column_names' do
          result = described_class.new(collection, collection_wrapper).column_names

          expect(result).to eq [:employee_number, :first_name, :last_name, :location_name, :created_by, :created_at]
        end
      end
    end

    describe '#each' do
      it 'should yield block to elements wrapped using collection_wrapper' do
        wrapped_collection = [EquipmentPresenter.new(Equipment.new)]
        success = false

        expect(collection_wrapper).to receive(:collection).and_return(wrapped_collection)

        sut = described_class.new(equipment_collection, collection_wrapper)

        sut.each { success = true }

        expect(success).to eq true
      end
    end
  end
end