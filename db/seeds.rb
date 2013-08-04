# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# Also called via rake db:reset

require_relative '../spec/support/object_mother'
include ObjectMother

customer = create_customer(name: 'Test Customer')

create_user(username: 'admin', password: 'Password123', roles: ['admin'], customer: customer)
create_user(username: 'equipment_user', password: 'Password123', roles: ['equipment'], customer: customer)
create_user(username: 'guest', password: 'Password123')

create_equipment(name: 'Meter', serial_number: 'ABC123', customer: customer, last_inspection_date: '01-01-2013',
                       inspection_interval: 'Annually', expiration_date: '03-01-2013', inspection_type: 'Inspectable',
                       notes: 'Fragile')

create_location(name: 'Golden', customer: customer)
create_location(name: 'Boulder', customer: customer)
create_location(name: 'Denver', customer: customer)