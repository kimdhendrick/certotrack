require 'spec_helper'

describe SortService do
  context 'equipment' do
    it 'should sort by name ascending' do
      create_equipment(name: 'zeta')
      create_equipment(name: 'beta')
      create_equipment(name: 'alpha')

      params = {
        sort: 'name',
        direction: 'asc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:name).should ==
        ['alpha', 'beta', 'zeta']
    end

    it 'should sort by name descending' do
      create_equipment(name: 'zeta')
      create_equipment(name: 'beta')
      create_equipment(name: 'alpha')

      params = {
        sort: 'name',
        direction: 'desc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:name).should ==
        ['zeta', 'beta', 'alpha']
    end

    it 'should sort by serial_number ascending' do
      create_equipment(serial_number: '222')
      create_equipment(serial_number: '333')
      create_equipment(serial_number: '111')

      params = {
        sort: 'serial_number',
        direction: 'asc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:serial_number).should ==
        ['111', '222', '333']
    end

    it 'should sort by serial_number descending' do
      create_equipment(serial_number: '222')
      create_equipment(serial_number: '333')
      create_equipment(serial_number: '111')

      params = {
        sort: 'serial_number',
        direction: 'desc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:serial_number).should ==
        ['333', '222', '111']
    end

    it 'should sort by status ascending' do
      create_expiring_equipment(customer: @my_customer)
      create_expired_equipment(customer: @my_customer)
      create_valid_equipment(customer: @my_customer)

      params = {
        sort: 'status_code',
        direction: 'asc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:status).should ==
        [Status::VALID, Status::EXPIRING, Status::EXPIRED]
    end

    it 'should sort by status descending' do
      create_expiring_equipment(customer: @my_customer)
      create_expired_equipment(customer: @my_customer)
      create_valid_equipment(customer: @my_customer)

      params = {
        sort: 'status_code',
        direction: 'desc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:status).should ==
        [Status::EXPIRED, Status::EXPIRING, Status::VALID]
    end

    it 'should sort by inspection_interval ascending' do
      create_equipment(inspection_interval: InspectionInterval::SIX_MONTHS.text)
      create_equipment(inspection_interval: InspectionInterval::TWO_YEARS.text)
      create_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text)
      create_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text)
      create_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text)
      create_equipment(inspection_interval: InspectionInterval::THREE_YEARS.text)
      create_equipment(inspection_interval: InspectionInterval::ONE_MONTH.text)
      create_equipment(inspection_interval: InspectionInterval::THREE_MONTHS.text)

      params = {
        sort: 'inspection_interval_code',
        direction: 'asc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:inspection_interval).should ==
        [
          InspectionInterval::ONE_MONTH.text,
          InspectionInterval::THREE_MONTHS.text,
          InspectionInterval::SIX_MONTHS.text,
          InspectionInterval::ONE_YEAR.text,
          InspectionInterval::TWO_YEARS.text,
          InspectionInterval::THREE_YEARS.text,
          InspectionInterval::FIVE_YEARS.text,
          InspectionInterval::NOT_REQUIRED.text
        ]
    end

    it 'should sort by inspection_interval descending' do
      create_equipment(inspection_interval: InspectionInterval::SIX_MONTHS.text)
      create_equipment(inspection_interval: InspectionInterval::TWO_YEARS.text)
      create_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text)
      create_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text)
      create_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text)
      create_equipment(inspection_interval: InspectionInterval::THREE_YEARS.text)
      create_equipment(inspection_interval: InspectionInterval::ONE_MONTH.text)
      create_equipment(inspection_interval: InspectionInterval::THREE_MONTHS.text)

      params = {
        sort: 'inspection_interval_code',
        direction: 'desc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:inspection_interval).should ==
        [
          InspectionInterval::NOT_REQUIRED.text,
          InspectionInterval::FIVE_YEARS.text,
          InspectionInterval::THREE_YEARS.text,
          InspectionInterval::TWO_YEARS.text,
          InspectionInterval::ONE_YEAR.text,
          InspectionInterval::SIX_MONTHS.text,
          InspectionInterval::THREE_MONTHS.text,
          InspectionInterval::ONE_MONTH.text
        ]
    end

    it 'should sort by last_inspection_date ascending' do
      middle_date = Date.new(2013, 6, 15)
      latest_date = Date.new(2013, 12, 31)
      earliest_date = Date.new(2013, 1, 1)

      create_equipment(last_inspection_date: middle_date)
      create_equipment(last_inspection_date: latest_date)
      create_equipment(last_inspection_date: earliest_date)

      params = {
        sort: 'last_inspection_date',
        direction: 'asc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:last_inspection_date).should ==
        [earliest_date, middle_date, latest_date]
    end

    it 'should sort by last_inspection_date descending' do
      middle_date = Date.new(2013, 6, 15)
      latest_date = Date.new(2013, 12, 31)
      earliest_date = Date.new(2013, 1, 1)

      create_equipment(last_inspection_date: middle_date)
      create_equipment(last_inspection_date: latest_date)
      create_equipment(last_inspection_date: earliest_date)

      params = {
        sort: 'last_inspection_date',
        direction: 'desc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:last_inspection_date).should ==
        [latest_date, middle_date, earliest_date]
    end

    it 'should sort by inspection_type ascending' do
      inspectable1 = create_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text)
      not_inspectable = create_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text)
      inspectable2 = create_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text)

      params = {
        sort: 'inspection_type',
        direction: 'asc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:inspection_type).should ==
        ["Inspectable", "Inspectable", "Non-Inspectable"]
    end

    it 'should sort by inspection_type descending' do
      create_equipment(inspection_interval: InspectionInterval::ONE_YEAR.text)
      create_equipment(inspection_interval: InspectionInterval::NOT_REQUIRED.text)
      create_equipment(inspection_interval: InspectionInterval::FIVE_YEARS.text)

      params = {
        sort: 'inspection_type',
        direction: 'desc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:inspection_type).should ==
        ["Non-Inspectable", "Inspectable", "Inspectable"]
    end

    it 'should sort by expiration_date ascending' do
      middle_date = Date.new(2013, 6, 15)
      latest_date = Date.new(2013, 12, 31)
      earliest_date = Date.new(2013, 1, 1)

      create_equipment(expiration_date: middle_date)
      create_equipment(expiration_date: latest_date)
      create_equipment(expiration_date: earliest_date)

      params = {
        sort: 'expiration_date',
        direction: 'asc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:expiration_date).should ==
        [earliest_date, middle_date, latest_date]
    end

    it 'should sort by expiration_date descending' do
      middle_date = Date.new(2013, 6, 15)
      latest_date = Date.new(2013, 12, 31)
      earliest_date = Date.new(2013, 1, 1)

      create_equipment(expiration_date: middle_date)
      create_equipment(expiration_date: latest_date)
      create_equipment(expiration_date: earliest_date)

      params = {
        sort: 'expiration_date',
        direction: 'desc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:expiration_date).should ==
        [latest_date, middle_date, earliest_date]
    end

    it 'should sort by assignee ascending' do
      middle_employee = create_employee(first_name: 'Bob', last_name: 'Baker')
      first_employee = create_employee(first_name: 'Albert', last_name: 'Alfonso')
      last_employee = create_employee(first_name: 'Zoe', last_name: 'Zephyr')

      first_location = create_location(name: 'Alcatraz')
      last_location = create_location(name: 'Zurich')
      middle_location = create_location(name: 'Burbank')

      create_equipment(employee: middle_employee)
      create_equipment(location: last_location)
      create_equipment(location: first_location)
      create_equipment(employee: last_employee)
      create_equipment(employee: first_employee)
      create_equipment(location: middle_location)

      params = {
        sort: 'assignee',
        direction: 'asc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:assignee).should ==
        ['Alcatraz', 'Alfonso, Albert', 'Baker, Bob', 'Burbank', 'Zephyr, Zoe', 'Zurich']
    end

    it 'should sort by assignee descending' do
      middle_employee = create_employee(first_name: 'Bob', last_name: 'Baker')
      first_employee = create_employee(first_name: 'Albert', last_name: 'Alfonso')
      last_employee = create_employee(first_name: 'Zoe', last_name: 'Zephyr')

      first_location = create_location(name: 'Alcatraz')
      last_location = create_location(name: 'Zurich')
      middle_location = create_location(name: 'Burbank')

      create_equipment(employee: middle_employee)
      create_equipment(location: last_location)
      create_equipment(location: first_location)
      create_equipment(employee: last_employee)
      create_equipment(employee: first_employee)
      create_equipment(location: middle_location)

      params = {
        sort: 'assignee',
        direction: 'desc'
      }

      SortService.new.sort(Equipment.all, params[:sort], params[:direction]).map(&:assignee).should ==
        ['Zurich', 'Zephyr, Zoe', 'Burbank', 'Baker, Bob', 'Alfonso, Albert', 'Alcatraz']
    end
  end
end