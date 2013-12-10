FactoryGirl.define do

  factory :service_type do

    sequence :name do |n|
      "service_type_#{n}"
    end

    interval_mileage 5000
    expiration_type 'By Mileage'
    customer
  end
end