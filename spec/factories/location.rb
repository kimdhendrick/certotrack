FactoryGirl.define do
  sequence :name do |n|
    "Denver-#{n}"
  end

  factory :location do
    name
    customer
  end
end