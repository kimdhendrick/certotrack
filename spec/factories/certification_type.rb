FactoryGirl.define do
  factory :certification_type do
    sequence :name do |n|
      "Scrum Master-#{n}"
    end

    interval Interval::ONE_YEAR.text

    factory :units_based_certification_type do
      units_required 1
    end
  end


end