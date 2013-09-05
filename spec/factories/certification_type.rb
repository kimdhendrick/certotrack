FactoryGirl.define do
  factory :certification_type do
    name 'Scrum Master'
    interval Interval::ONE_YEAR.text
  end
end