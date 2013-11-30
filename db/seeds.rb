# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# Also called via rake db:reset

customer = Customer.create!(name: 'Test Customer')

User.create!(username: 'admin', password: 'Password123', email: 'admin@example.com', roles: ['admin'], customer: customer, first_name: 'First', last_name: 'Last')
User.create!(username: 'equipment_user', password: 'Password123', email: 'equipment_user@example.com', roles: ['equipment'], customer: customer, first_name: 'First', last_name: 'Last')
User.create!(username: 'certification_user', password: 'Password123', email: 'certification_user@example.com', roles: ['certification'], customer: customer, first_name: 'First', last_name: 'Last')
User.create!(username: 'vehicle_user', password: 'Password123', email: 'vehicle_user@example.com', roles: ['vehicle'], customer: customer, first_name: 'First', last_name: 'Last')
User.create!(username: 'full_rights_user', password: 'Password123', email: 'full_rights_user@example.com', roles: ['equipment', 'certification', 'vehicle'], customer: customer, first_name: 'First', last_name: 'Last')
User.create!(username: 'guest', password: 'Password123', email: 'guest@example.com', first_name: 'First', last_name: 'Last', customer: customer)

golden = Location.create!(name: 'Golden', customer: customer)
boulder = Location.create!(name: 'Boulder', customer: customer)
denver = Location.create!(name: 'Denver', customer: customer)
john = Employee.create!(first_name: 'John', last_name: 'Doe', customer: customer, employee_number: 'JD123', location_id: golden)
sue = Employee.create!(first_name: 'Sue', last_name: 'Smith', customer: customer, employee_number: 'SS123', location_id: denver)

Equipment.create!(name: 'Meter', serial_number: 'ABC123', customer: customer, last_inspection_date: '01-01-2013',
                       inspection_interval: Interval::ONE_YEAR.text, expiration_date: '01-01-2014',
                       comments: 'Fragile', location: golden)

Equipment.create!(name: 'Cart', serial_number: '888-EFZ', customer: customer, last_inspection_date: '02-01-2013',
                       inspection_interval: Interval::ONE_YEAR.text, expiration_date: '02-01-2014',
                       comments: 'Heavy', employee: sue)

Equipment.create!(name: 'Box', serial_number: 'Box 555', customer: customer, last_inspection_date: '02-01-2013',
                       inspection_interval: Interval::ONE_YEAR.text, expiration_date: '02-01-2014',
                       comments: 'Heavy')

Equipment.create!(name: 'Light cart', serial_number: 'Cart LI1', customer: customer, last_inspection_date: Date.today-45.days,
                       inspection_interval: Interval::ONE_MONTH.text, expiration_date: Date.yesterday,
                       comments: 'Light')

Equipment.create!(name: 'Air Bottle', serial_number: 'SCOTT', customer: customer, last_inspection_date: Date.today,
                       inspection_interval: Interval::ONE_MONTH.text, expiration_date: Date.today + 59.days,
                       comments: 'Full')

Equipment.create!(name: 'Mobile Data Computer', serial_number: 'MDC999', customer: customer, last_inspection_date: Date.today,
                       inspection_interval: Interval::NOT_REQUIRED.text)

Vehicle.create!(vehicle_number: '987345', vin: '1M8GDM9AXKP042788', license_plate: 'ABC-123',
                year: 2013, make: 'Chevrolet', vehicle_model: 'Chevette', mileage: 10000, location: denver, customer: customer)

Vehicle.create!(vehicle_number: '34987', vin: '2B8GDM9AXKP042790', license_plate: '123-ABC',
                year: 1999, make: 'Dodge', vehicle_model: 'Dart', mileage: 20000, location: golden, customer: customer)

Vehicle.create!(vehicle_number: '77777', vin: '3C8GDM9AXKP042701', license_plate: '789-XYZ',
                year: 1970, make: 'Buick', vehicle_model: 'Riviera', mileage: 56000, location: boulder, customer: customer)