FactoryGirl.define do

  sequence :account_number do |n|
    "account_number#{n}"
  end

  factory :customer do
    name 'My Customer'
    account_number
    contact_person_name 'Contact Person'
    contact_email 'customer_contact@example.com'
  end
end