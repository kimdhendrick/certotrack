FactoryGirl.define do
  factory :certification do
    employee
    certification_type
    association :active_certification_period, factory: :certification_period
    factory :units_based_certification do
      association :certification_type, factory: :units_based_certification_type
    end
  end
end