FactoryGirl.define do
    factory :service do
    vehicle
    service_type
    customer { service_type.customer || employee.customer }
    association :active_service_period, factory: :service_period

    after(:create) do |service|
      service.active_service_period.service = service
      service.save if service.persisted?
    end
  end
end