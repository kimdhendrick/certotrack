FactoryGirl.define do

  sequence :serial_number do |n|
    "782-888-DKHE-#{n}"
  end
  
  factory :equipment do
    name 'Meter'
    last_inspection_date Date.new(2000, 1, 1)
    inspection_interval Interval::ONE_YEAR.text
    serial_number
    customer

    factory :location_assigned_equipment do
      location
    end

    factory :valid_equipment do
      expiration_date Date.today + 61.days
    end

    factory :expired_equipment do
      expiration_date Date.yesterday
    end

    factory :expiring_equipment do
      expiration_date Date.tomorrow
    end

    factory :noninspectable_equipment do
      inspection_interval Interval::NOT_REQUIRED.text
      last_inspection_date nil
    end
  end
end