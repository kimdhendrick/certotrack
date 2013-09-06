FactoryGirl.define do

  sequence :username do |n|
    "username_#{n}"
  end

  sequence :email do |n|
    "email_#{n}@email.com"
  end

  factory :user do
    username
    first_name 'First'
    last_name 'Last'
    email
    password 'Password123'
    password_confirmation 'Password123'
  end
end