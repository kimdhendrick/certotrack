FactoryGirl.define do

  sequence :serial_number do |n|
    "782-888-DKHE-#{n}"
  end
  
  factory :equipment do
    name 'Meter'
    last_inspection_date Date.new(2000, 1, 1)
    inspection_interval Interval::ONE_YEAR.text
    serial_number
  end
end