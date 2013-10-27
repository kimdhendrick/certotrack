FactoryGirl.define do
  factory :certification, aliases: [:date_based_certification] do
    employee
    certification_type
    customer { certification_type.customer || employee.customer }
    association :active_certification_period, factory: :certification_period
    factory :units_based_certification do
      association :certification_type, factory: :units_based_certification_type
      association :active_certification_period, factory: :certification_period, units_achieved: 1
    end

    after(:create) do |certification|
      certification.active_certification_period.certification = certification
      certification.save if certification.persisted?
    end
  end
end