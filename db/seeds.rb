# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# Also called via rake db:reset

require_relative '../spec/support/object_mother'
include ObjectMother

customer = create_customer(name: 'Test Customer')

create_user(username: 'admin', password: 'Password123', roles: ['admin'], customer: customer)
create_user(username: 'equipment_user', password: 'Password123', roles: ['equipment'], customer: customer)
create_user(username: 'guest', password: 'Password123')

golden = create_location(name: 'Golden', customer: customer)
boulder = create_location(name: 'Boulder', customer: customer)
denver = create_location(name: 'Denver', customer: customer)
john = create_employee(first_name: 'John', last_name: 'Doe', customer: customer, employee_number: 'JD123', location_id: golden)
sue = create_employee(first_name: 'Sue', last_name: 'Smith', customer: customer, employee_number: 'JD123', location_id: denver)

create_equipment(name: 'Meter', serial_number: 'ABC123', customer: customer, last_inspection_date: '01-01-2013',
                       inspection_interval: 'Annually', expiration_date: '01-01-2014', inspection_type: 'Inspectable',
                       notes: 'Fragile', location: golden)

create_equipment(name: 'Cart', serial_number: '888-EFZ', customer: customer, last_inspection_date: '02-01-2013',
                       inspection_interval: 'Annually', expiration_date: '02-01-2014', inspection_type: 'Inspectable',
                       notes: 'Heavy', employee: sue)

create_equipment(name: 'Box', serial_number: 'Box 555', customer: customer, last_inspection_date: '02-01-2013',
                       inspection_interval: 'Annually', expiration_date: '02-01-2014', inspection_type: 'Inspectable',
                       notes: 'Heavy')
