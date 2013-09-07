FactoryGirl.define do
  sequence :employee_number do |n|
    "876ABC-#{n}"
  end
  
  factory :employee do
    first_name 'John'
    last_name 'Smith'
    employee_number
    customer
  end
end