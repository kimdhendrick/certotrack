require 'spec_helper'

module Export
  describe CsvPresenter do
    describe '#present' do
      it 'can present an empty collection' do
        CsvPresenter.new([]).present.should == "No results found\n"
      end

      context 'exporting equipment' do
        before do
          create(
            :equipment,
            name: 'Box',
            serial_number: 'MySerialNumber',
            last_inspection_date: Date.new(2013, 12, 15),
            expiration_date: Date.new(2016, 12, 20),
            inspection_interval: 'Annually',
            created_by: 'username'
          )
        end

        it 'should have the right equipment headers' do
          results = CsvPresenter.new(Equipment.all).present

          results.split("\n")[0].should == 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created By User,Created Date'
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
          data_results[8].should == 'username'
          data_results[9].should == "#{Date.current.strftime("%m/%d/%Y")}"
        end
      end

      context 'exporting certifications' do
        before do
          employee = create(
            :employee,
            first_name: 'Joe',
            last_name: 'Brown'
          )
          certification_type = create(:certification_type, units_required: 10, name: 'CPR')
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
        end

        it 'should have the right headers' do
          results = CsvPresenter.new(Certification.all).present

          results.split("\n")[0].should == 'Employee,Certification Type,Status,Units Achieved,Last Certification Date,Expiration Date,Trainer,Created By User,Created Date,Comments'
        end

        it 'should have the right data' do
          Certification.count.should == 1

          results = CsvPresenter.new(Certification.all).present

          data_results = results.split("\n")[1].split(',')

          data_results.should ==
            ["\"Brown", " Joe\"", 'CPR', 'Valid', '12', '01/02/2013', '01/02/2014', 'Trainer Tom', 'username', "#{Date.current.strftime('%m/%d/%Y')}", 'Well done']
        end
      end

      context 'exporting employees' do
        before do
          create(
            :employee,
            employee_number: 'JB888',
            first_name: 'Joe',
            last_name: 'Brown',
            location: create(:location, name: 'Denver'),
            created_by: 'Me'
          )
        end

        it 'should have the right headers' do
          results = CsvPresenter.new(Employee.all).present

          results.split("\n")[0].should == 'Employee Number,First Name,Last Name,Location,Created By User,Created Date'
        end

        it 'should have the right data' do
          Employee.count.should == 1

          results = CsvPresenter.new(Employee.all).present

          data_results = results.split("\n")[1].split(',')

          data_results.should ==
            ['JB888', 'Joe', 'Brown', 'Denver', 'Me', "#{Date.current.strftime('%m/%d/%Y')}"]
        end
      end

      context 'exporting customers' do
        before do
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
        end

        it 'should have the right headers' do
          results = CsvPresenter.new(Customer.all).present

          results.split("\n")[0].should == 'Name,Account Number,Contact Person Name,Contact Email,Contact Phone Number,Address 1,Address 2,City,State,Zip,Active,Equipment Access,Certification Access,Vehicle Access,Created Date'
        end

        it 'should have the right data' do
          Customer.count.should == 1

          results = CsvPresenter.new(Customer.all).present

          data_results = results.split("\n")[1].split(',')

          data_results.should ==
            ['City Of Something', 'ACTNUM111', 'Someone Special', 'email@address.com', '303-222-4232',
             '100 Main St', 'Suite 100', 'Boston', 'MA', '12333', 'Yes', 'Yes', 'Yes', 'Yes', "#{Date.current.strftime('%m/%d/%Y')}"]
        end
      end

      context 'exporting users' do
        before do
          create(
            :user,
            username: 'username123',
            first_name: 'Joe',
            last_name: 'Smith',
            email: 'jsmith@example.com',
            customer: create(:customer, name: 'My Customer'),
            expiration_notification_interval: 'Never'
          )
        end

        it 'should have the right headers' do
          results = CsvPresenter.new(User.all).present

          results.split("\n")[0].should == 'Username,First Name,Last Name,Email Address,Notification Interval,Customer,Created Date'
        end

        it 'should have the right data' do
          User.count.should == 1

          results = CsvPresenter.new(User.all).present

          data_results = results.split("\n")[1].split(',')

          data_results.should ==
            ['username123', 'Joe', 'Smith', 'jsmith@example.com', 'Never', 'My Customer', "#{Date.current.strftime('%m/%d/%Y')}"]
        end
      end
    end
  end
end