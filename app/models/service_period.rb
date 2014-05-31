class ServicePeriod < ActiveRecord::Base

  belongs_to :service

  validates_date :start_date,
                 :before => lambda { 100.years.from_now }, :after => lambda { 100.years.ago },
                 presence: true,
                 if: :_require_start_date?

  validates :start_mileage,
            presence: true,
            if: :_require_start_mileage?

  validates :start_mileage, numericality: {greater_than_or_equal_to: 0}, allow_nil: true

  def _require_start_date?
    service.nil? || service.expiration_type.nil? || service.date_expiration_type?
  end

  def _require_start_mileage?
    service.nil? || service.expiration_type.nil? || service.mileage_expiration_type?
  end
end
