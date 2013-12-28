FactoryGirl.define do
  factory :service_period do
    start_date { Date.new(2013, 5, 15) }
    start_mileage 10000
    comments 'Comments'
  end
end