# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# Also called via rake db:reset

require_relative '../app/helpers/object_mother.rb'
include ObjectMother

customer = create_valid_customer(name: 'Test Customer')

create_valid_user(username: 'admin', password: 'Password123', roles: ['admin'], customer: customer)
create_valid_user(username: 'equipment_user', password: 'Password123', roles: ['equipment'], customer: customer)
create_valid_user(username: 'guest', password: 'Password123')

create_valid_equipment(name: 'Meter', serial_number: 'ABC123', customer: customer, last_inspection_date: '01-01-2013',
                       inspection_interval: 'Annually', expiration_date: '03-01-2013', inspection_type: 'Inspectable',
                       notes: 'Fragile')