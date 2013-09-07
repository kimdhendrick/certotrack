require 'spec_helper'
describe SearchService do

  describe 'search by Equipment' do
    it 'should search by name' do
      match = create(:equipment, name: 'Meter123')
      no_match = create(:equipment, name: 'Box')

      SearchService.new.search(Equipment.all, {name: 'Meter123'}).should == [match]
      SearchService.new.search(Equipment.all, {name: 'METER123'}).should == [match]
      SearchService.new.search(Equipment.all, {name: 'meter123'}).should == [match]
      SearchService.new.search(Equipment.all, {name: 'Meter'}).should == [match]
      SearchService.new.search(Equipment.all, {name: 'eter123'}).should == [match]
      SearchService.new.search(Equipment.all, {name: 'ter12'}).should == [match]
    end

    it 'should search by serial_number' do
      match = create(:equipment, serial_number: 'ABC123')
      no_match = create(:equipment, serial_number: 'XYZ')

      SearchService.new.search(Equipment.all, {serial_number: 'ABC123'}).should == [match]
      SearchService.new.search(Equipment.all, {serial_number: 'abc123'}).should == [match]
      SearchService.new.search(Equipment.all, {serial_number: 'aBc123'}).should == [match]
      SearchService.new.search(Equipment.all, {serial_number: 'ABC'}).should == [match]
      SearchService.new.search(Equipment.all, {serial_number: '123'}).should == [match]
      SearchService.new.search(Equipment.all, {serial_number: 'BC12'}).should == [match]
    end

    it 'should search by employee_id' do
      match = create(:equipment, employee_id: 1)
      no_match = create(:equipment, employee_id: 2)

      SearchService.new.search(Equipment.all, {employee_id: 1}).should == [match]
    end

    it 'should search by location_id' do
      match = create(:equipment, location_id: 1)
      no_match = create(:equipment, location_id: 2)

      SearchService.new.search(Equipment.all, {location_id: 1}).should == [match]
    end

    it 'should search by all fields' do
      employee_match = create(:equipment, employee_id: 7)
      location_match = create(:equipment, location_id: 3)
      name_match = create(:equipment, name: 'Meter123')
      serial_number_match = create(:equipment, serial_number: 'ABC123')
      no_match = create(:equipment, name: 'blah', serial_number: 'blah', employee_id: nil, location_id: nil)

      search_params =
        {
          name: 'Meter123',
          serial_number: 'ABC123',
          employee_id: 7,
          location_id: 3
        }

      SearchService.new.search(Equipment.all, search_params).should =~
        [
          employee_match,
          location_match,
          name_match,
          serial_number_match
        ]
    end

    it 'should search by name OR serial_number' do
      match = create(:equipment, name: 'Meter', serial_number: 'ABC123')
      SearchService.new.search(Equipment.all, {name: 'Meter', serial_number: 'ABC123'}).should == [match]
    end
  end

  describe 'search by Certification Type' do
    it 'should search by name' do
      match = create(:certification_type, name: 'Examination')
      no_match = create(:certification_type, name: 'CPR')

      SearchService.new.search(CertificationType.all, {name: 'Examination'}).should == [match]
      SearchService.new.search(CertificationType.all, {name: 'EXAMINATION'}).should == [match]
      SearchService.new.search(CertificationType.all, {name: 'examination'}).should == [match]
      SearchService.new.search(CertificationType.all, {name: 'Exam'}).should == [match]
      SearchService.new.search(CertificationType.all, {name: 'ination'}).should == [match]
      SearchService.new.search(CertificationType.all, {name: 'amina'}).should == [match]
    end
  end
end