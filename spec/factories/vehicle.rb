FactoryGirl.define do

  sequence :vin do |n|
    "%017d" % n
  end

  sequence :vehicle_number do |n|
    "vehicle_number_#{n}"
  end

  sequence :license_plate do |n|
    "ABC-123-#{n}"
  end

  factory :vehicle do
    vehicle_number
    vin
    license_plate
    year 2010
    make 'Ford'
    vehicle_model 'F-250'
    mileage 6000
    location
    customer
    created_by 'username'
  end
end