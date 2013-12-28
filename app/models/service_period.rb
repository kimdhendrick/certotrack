class ServicePeriod < ActiveRecord::Base

  belongs_to :service

  validates_date :start_date,
                 :before => lambda { 100.years.from_now }, :after => lambda { 100.years.ago },
                 presence: true, if: :date_expiration_type?

  validates :start_mileage, presence: true, if: :mileage_expiration_type?

  def date_expiration_type?
    service.try(&:date_expiration_type?)
  end

  def mileage_expiration_type?
    service.try(&:mileage_expiration_type?)
  end
end
