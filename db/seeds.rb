# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# Also called via rake db:reset

equipment_customer = Customer.create!(name: 'Equipment Customer', equipment_access: true)
full_rights_customer = Customer.create!(
  name: 'Full Rights Customer',
  equipment_access: true,
  certification_access: true,
  vehicle_access: true
)
guest_customer = Customer.create!(name: 'Guest Customer')
admin_customer = Customer.create!(name: 'CertoTrack')

User.create!(username: 'admin', password: 'Password123', email: 'admin@example.com', admin: true, customer: admin_customer, first_name: 'First', last_name: 'Last')
User.create!(username: 'equipment_user', password: 'Password123', email: 'equipment_user@example.com', roles: equipment_customer.roles, customer: equipment_customer, first_name: 'First', last_name: 'Last')
User.create!(username: 'full_rights_user', password: 'Password123', email: 'full_rights_user@example.com', roles: full_rights_customer.roles, customer: full_rights_customer, first_name: 'First', last_name: 'Last')
User.create!(username: 'guest', password: 'Password123', email: 'guest@example.com', first_name: 'First', last_name: 'Last', customer: guest_customer)

# Equipment customer data
golden = Location.create!(name: 'Golden', customer: equipment_customer)
john = Employee.create!(first_name: 'John', last_name: 'Doe', customer: equipment_customer, employee_number: 'JD123', location_id: golden)
sue = Employee.create!(first_name: 'Sue', last_name: 'Smith', customer: equipment_customer, employee_number: 'SS123', location_id: golden)

Equipment.create!(name: 'Meter', serial_number: 'ABC123', customer: equipment_customer, last_inspection_date: '01-01-2013',
                  inspection_interval: Interval::ONE_YEAR.text, expiration_date: '01-01-2014',
                  comments: 'Fragile', location: golden)

Equipment.create!(name: 'Cart', serial_number: '888-EFZ', customer: equipment_customer, last_inspection_date: '02-01-2013',
                  inspection_interval: Interval::ONE_YEAR.text, expiration_date: '02-01-2014',
                  comments: 'Heavy', employee: sue)

Equipment.create!(name: 'Box', serial_number: 'Box 555', customer: equipment_customer, last_inspection_date: '02-01-2013',
                  inspection_interval: Interval::ONE_YEAR.text, expiration_date: '02-01-2014',
                  comments: 'Heavy')

Equipment.create!(name: 'Light cart', serial_number: 'Cart LI1', customer: equipment_customer, last_inspection_date: Date.today-45.days,
                  inspection_interval: Interval::ONE_MONTH.text, expiration_date: Date.yesterday,
                  comments: 'Light')

Equipment.create!(name: 'Air Bottle', serial_number: 'SCOTT', customer: equipment_customer, last_inspection_date: Date.today,
                  inspection_interval: Interval::ONE_MONTH.text, expiration_date: Date.today + 59.days,
                  comments: 'Full')

Equipment.create!(name: 'Mobile Data Computer', serial_number: 'MDC999', customer: equipment_customer, last_inspection_date: Date.today,
                  inspection_interval: Interval::NOT_REQUIRED.text)


# Full rights customer data
boulder = Location.create!(name: 'Boulder', customer: full_rights_customer)
denver = Location.create!(name: 'Denver', customer: full_rights_customer)
tom = Employee.create!(first_name: 'Tom', last_name: 'Doe', customer: full_rights_customer, employee_number: 'TD123', location_id: boulder)
mary = Employee.create!(first_name: 'Mary', last_name: 'Smith', customer: full_rights_customer, employee_number: 'MS123', location_id: denver)


Vehicle.create!(vehicle_number: '987345', vin: '1M8GDM9AXKP042788', license_plate: 'ABC-123',
                year: 2013, make: 'Chevrolet', vehicle_model: 'Chevette', mileage: 10000, location: denver, customer: full_rights_customer)

Vehicle.create!(vehicle_number: '34987', vin: '2B8GDM9AXKP042790', license_plate: '123-ABC',
                year: 1999, make: 'Dodge', vehicle_model: 'Dart', mileage: 20000, location: boulder, customer: full_rights_customer)

Vehicle.create!(vehicle_number: '77777', vin: '3C8GDM9AXKP042701', license_plate: '789-XYZ',
                year: 1970, make: 'Buick', vehicle_model: 'Riviera', mileage: 56000, location: boulder, customer: full_rights_customer)

Equipment.create!(name: 'Gas Bottle', serial_number: 'A-SCOTT', customer: full_rights_customer, last_inspection_date: Date.today,
                  inspection_interval: Interval::ONE_MONTH.text, expiration_date: Date.today + 59.days,
                  comments: 'Full')

Equipment.create!(name: 'Portable Data Computer', serial_number: 'A-MDC999', customer: full_rights_customer, last_inspection_date: Date.today,
                  inspection_interval: Interval::NOT_REQUIRED.text)

ServiceType.create!(name: 'Oil change', expiration_type: ServiceType::EXPIRATION_TYPE_BY_MILEAGE, interval_mileage: 5000, customer: full_rights_customer)
ServiceType.create!(name: 'Pump check', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE_AND_MILEAGE, interval_mileage: 10000, interval_date: Interval::ONE_MONTH.text, customer: full_rights_customer)
ServiceType.create!(name: 'Tire rotation', expiration_type: ServiceType::EXPIRATION_TYPE_BY_DATE, interval_date: Interval::ONE_YEAR.text, customer: full_rights_customer)