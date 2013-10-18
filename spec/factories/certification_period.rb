FactoryGirl.define do
  factory :certification_period do
    trainer 'Trainer'
    start_date { Date.new(2013, 5, 15) }
    comments 'Comments'

    factory :units_based_certification_period do
      units_achieved 42
    end
  end
end