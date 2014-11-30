require 'spec_helper'

describe SearchService do
  describe 'search by Certifications' do
    let (:certifications) { Certification.all.joins(:certification_type).joins(:employee) }

    it 'should search by name to match certification type name' do
      match = create(:certification, certification_type: create(:certification_type, name: 'Inspector123'))
      no_match = create(:certification, certification_type: create(:certification_type, name: 'Routine'))

      SearchService.new.search(certifications, {certification_type_or_employee_name: 'Inspector123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'INSPECTOR123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'inspector123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'Inspector'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'spector123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'tor12'}).should == [match]
    end

    it 'should search by name to match employee first name' do
      match = create(:certification, employee: create(:employee, first_name: 'Jilly123'))
      no_match = create(:certification, employee: create(:employee, first_name: 'Bobby'))

      SearchService.new.search(certifications, {certification_type_or_employee_name: 'Jilly123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'JILLY123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'jilly123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'Jilly'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'lly123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'lly1'}).should == [match]
    end

    it 'should search by name to match employee last name' do
      match = create(:certification, employee: create(:employee, last_name: 'Jilly123'))
      no_match = create(:certification, employee: create(:employee, last_name: 'Bobby'))

      SearchService.new.search(certifications, {certification_type_or_employee_name: 'Jilly123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'JILLY123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'jilly123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'Jilly'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'lly123'}).should == [match]
      SearchService.new.search(certifications, {certification_type_or_employee_name: 'lly1'}).should == [match]
    end

    it 'should search by location name' do
      denver = create(:location, name: 'Denver')
      golden = create(:location, name: 'Golden')
      golden_certification = create(:certification, employee: create(:employee, location: golden))
      denver_location = create(:certification, employee: create(:employee, location: denver))

      SearchService.new.search(certifications, {location_id: golden.id}).should == [golden_certification]
      SearchService.new.search(certifications, {location_id: denver.id}).should == [denver_location]
    end

    it 'should search by type of certification type' do
      units_based_certification_type = create(:units_based_certification_type)
      date_based_certification_type = create(:certification_type)
      units_based = create(:certification, certification_type: units_based_certification_type)
      date_based = create(:certification, certification_type: date_based_certification_type)

      certifications = Certification.all.joins(:certification_type).joins(:employee)

      SearchService.new.search(certifications, {certification_type: 'units_based'}).should == [units_based]
      SearchService.new.search(certifications, {certification_type: 'date_based'}).should == [date_based]
    end

    it 'should search by certification type name AND location' do
      denver = create(:location, name: 'Denver')
      golden = create(:location, name: 'Golden')
      inspector_certification_type = create(:certification_type, name: 'Inspector')
      another_certification_type = create(:certification_type, name: 'Something else')

      matches_name_but_not_location = create(:certification,
                     employee: create(:employee, location: denver),
                     certification_type: inspector_certification_type)
      matches_location_but_not_name = create(:certification,
                     employee: create(:employee, location: golden),
                     certification_type: another_certification_type)
      matches_name_and_location = create(:certification,
                     employee: create(:employee, location: golden),
                     certification_type: inspector_certification_type)

      SearchService.new.search(certifications, {name: 'Inspector', location_id: golden.id}).should == [matches_name_and_location]
    end

    it 'should search by certification type AND name' do
      units_based_certification_type = create(:certification_type, name: 'CPR', units_required: 10)
      a_different_units_based_certification_type = create(:certification_type, name: 'Something different', units_required: 10)
      date_based_certification_type_with_same_name = create(:certification_type, name: 'CPR', units_required: 0)
      matches_certification_type_but_not_name = create(:certification,
                     certification_type: a_different_units_based_certification_type)
      matches_name_but_not_certification_type = create(:certification,
                     certification_type: date_based_certification_type_with_same_name)
      matches_name_and_certification_type = create(:certification,
                     certification_type: units_based_certification_type)

      SearchService.new.search(certifications, {name: 'CPR', certification_type: 'units_based'}).should == [matches_name_and_certification_type]
    end
  end

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

    it 'should search by ANDing all fields' do
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

      SearchService.new.search(Equipment.all, search_params).should == []
    end

    it 'should search by name AND serial_number' do
      matches_name_but_not_serial_number = create(:equipment, name: 'Meter', serial_number: 'XYZ')
      matches_serial_number_but_not_name = create(:equipment, name: 'Another name', serial_number: 'ABC123')
      match = create(:equipment, name: 'Meter', serial_number: 'ABC123')
      SearchService.new.search(Equipment.all, {name: 'Meter', serial_number: 'ABC123'}).should == [match]
    end
    
    it 'should search by name AND employee_id' do
      matches_name_but_not_employee = create(:equipment, name: 'Meter', employee_id: 99)
      matches_employee_but_not_name = create(:equipment, name: 'Another name', employee_id: 5)
      match = create(:equipment, name: 'Meter', employee_id: 5)
      SearchService.new.search(Equipment.all, {name: 'Meter', employee_id: 5}).should == [match]
    end
    
    it 'should search by name AND location_id' do
      matches_name_but_not_location_id = create(:equipment, name: 'Meter', location_id: 99)
      matches_location_id_but_not_name = create(:equipment, name: 'Another name', location_id: 5)
      match = create(:equipment, name: 'Meter', location_id: 5)
      SearchService.new.search(Equipment.all, {name: 'Meter', location_id: 5}).should == [match]
    end

    it 'should search by employee_id AND location_id' do
      matches_employee_but_not_location = create(:equipment, employee_id: 5, location_id: 99)
      matches_location_but_not_employee = create(:equipment, employee_id: 99, location_id: 5)
      SearchService.new.search(Equipment.all, {employee_id: 5, location_id: 5}).should =~ []
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

  describe 'search by Vehicle' do
    it 'should search by make' do
      match = create(:vehicle, make: 'Toyota')
      no_match = create(:vehicle, make: 'Ford')

      SearchService.new.search(Vehicle.all, {make: 'Toyota'}).should == [match]
      SearchService.new.search(Vehicle.all, {make: 'TOYOTA'}).should == [match]
      SearchService.new.search(Vehicle.all, {make: 'toyota'}).should == [match]
      SearchService.new.search(Vehicle.all, {make: 'Toy'}).should == [match]
      SearchService.new.search(Vehicle.all, {make: 'ota'}).should == [match]
      SearchService.new.search(Vehicle.all, {make: 'yot'}).should == [match]
    end

    it 'should search by vehicle_model' do
      match = create(:vehicle, vehicle_model: 'Corolla')
      no_match = create(:vehicle, vehicle_model: 'Tundra')

      SearchService.new.search(Vehicle.all, {vehicle_model: 'Corolla'}).should == [match]
      SearchService.new.search(Vehicle.all, {vehicle_model: 'COROLLA'}).should == [match]
      SearchService.new.search(Vehicle.all, {vehicle_model: 'corolla'}).should == [match]
      SearchService.new.search(Vehicle.all, {vehicle_model: 'Cor'}).should == [match]
      SearchService.new.search(Vehicle.all, {vehicle_model: 'lla'}).should == [match]
      SearchService.new.search(Vehicle.all, {vehicle_model: 'roll'}).should == [match]
    end

    it 'should search by make AND model' do
      matches_make_but_not_model = create(:vehicle, make: 'Ford', vehicle_model: 'something')
      matches_model_but_not_make = create(:vehicle, vehicle_model: 'Tempo', make: 'something')
      match = create(:vehicle, make: 'Ford', vehicle_model: 'Tempo')

      SearchService.new.search(Vehicle.all, {vehicle_model: 'Tempo', make: 'Ford'}).should == [match]
    end
  end
end