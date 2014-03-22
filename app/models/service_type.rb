class ServiceType < ActiveRecord::Base
  include DeletionPrevention

  EXPIRATION_TYPE_BY_DATE = 'By Date'
  EXPIRATION_TYPE_BY_MILEAGE = 'By Mileage'
  EXPIRATION_TYPE_BY_DATE_AND_MILEAGE = 'By Date and Mileage'

  EXPIRATION_TYPES = [EXPIRATION_TYPE_BY_DATE,
                      EXPIRATION_TYPE_BY_MILEAGE,
                      EXPIRATION_TYPE_BY_DATE_AND_MILEAGE]

  INTERVAL_MILEAGES = [3000, 5000, 10000, 12000, 15000, 20000, 50000]

  belongs_to :customer
  has_many :services, autosave: true

  validates_presence_of :name,
                        :customer,
                        :created_by

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
                in: INTERVAL_MILEAGES,
                message: 'invalid value',
                allow_nil: true
              }
  validates_presence_of :expiration_type
  validates :expiration_type,
            inclusion:
              {
                in: EXPIRATION_TYPES,
                message: 'invalid value'
              }
  validate :_date_or_mileage_required

  before_destroy :_prevent_deletion_when_services

  def mileage_expiration_type?
    [EXPIRATION_TYPE_BY_MILEAGE, EXPIRATION_TYPE_BY_DATE_AND_MILEAGE].include?(expiration_type)
  end

  def date_expiration_type?
    [EXPIRATION_TYPE_BY_DATE, EXPIRATION_TYPE_BY_DATE_AND_MILEAGE].include?(expiration_type)
  end

  private

  def _prevent_deletion_when_services
    prevent_deletion_of(
      services,
      'This Service Type is assigned to existing Vehicle(s). You must remove the vehicle assignment(s) before removing it.'
    )
  end

  def _date_or_mileage_required
    return if interval_date.present? || interval_mileage.present?

    errors.add(:interval_date, 'or mileage required')
    errors.add(:interval_mileage, 'or date required')
  end
end