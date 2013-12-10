class ServiceType < ActiveRecord::Base

  EXPIRATION_TYPE_BY_DATE = 'By Date'
  EXPIRATION_TYPE_BY_MILEAGE = 'By Mileage'
  EXPIRATION_TYPE_BY_DATE_AND_MILEAGE = 'By Date and Mileage'

  belongs_to :customer

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :customer_id, case_sensitive: false
  validates :interval_date,
            inclusion:
              {
                in: Interval.all.map(&:text),
                message: 'invalid value',
                allow_nil: true
              }
  validates :interval_mileage,
            inclusion:
              {
                in: [3000, 5000, 10000],
                message: 'invalid value',
                allow_nil: true
              }
  validates_presence_of :expiration_type
  validates :expiration_type,
            inclusion:
              {
                in: [EXPIRATION_TYPE_BY_DATE,
                     EXPIRATION_TYPE_BY_MILEAGE,
                     EXPIRATION_TYPE_BY_DATE_AND_MILEAGE],
                message: 'invalid value'
              }
  validate :_date_or_mileage_required

  private

  def _date_or_mileage_required
    return if interval_date.present? || interval_mileage.present?

    errors.add(:interval_date, 'or mileage required')
    errors.add(:interval_mileage, 'or date required')
  end
end