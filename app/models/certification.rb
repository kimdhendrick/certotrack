class Certification < ActiveRecord::Base
  include SortableByStatus

  belongs_to :certification_type
  belongs_to :employee
  belongs_to :customer
  has_one :active_certification_period, class_name: 'CertificationPeriod', autosave: true

  validates_uniqueness_of :certification_type_id, scope: :employee_id, message: "already assigned to this Employee. Please update existing Certification."

  validates_presence_of :active_certification_period,
                        :certification_type,
                        :customer

  delegate :comments, to: :active_certification_period
  delegate :comments=, to: :active_certification_period
  delegate :trainer, to: :active_certification_period
  delegate :trainer=, to: :active_certification_period
  delegate :units_achieved, to: :active_certification_period
  delegate :units_achieved=, to: :active_certification_period

  def expiration_date
    active_certification_period.end_date
  end

  def name
    certification_type.name
  end

  def units_based?
    certification_type.units_based?
  end

  def expiration_date=(date)
    active_certification_period.end_date=(date)
  end

  def last_certification_date
    active_certification_period.try(:start_date)
  end

  def last_certification_date=(date)
    if active_certification_period.present?
      active_certification_period.start_date=(date)
    end
  end

  def status
    units_based? ?
      _calculate_status_for_units_based :
      _calculate_status_for_non_units_based
  end

  def na?
    !expiration_date.present?
  end

  def expired?
    expiration_date.present? && expiration_date <= Date.today
  end

  def expiring?
    expiration_date.present? && !expired? && expiration_date < Date.today + 60.days
  end

  def pending?
    expiration_date.present? && !expired? && !achieved_units_required?
  end

  def achieved_units_required?
    units_achieved >= certification_type.units_required
  end

  def recertify?
    !achieved_units_required? && !pending?
  end

  def sort_key
    name
  end

  private

  def _calculate_status_for_non_units_based
    return Status::NA if na?
    return Status::EXPIRED if expired?
    return Status::EXPIRING if expiring?
    Status::VALID
  end

  def _calculate_status_for_units_based
    return Status::VALID if achieved_units_required?
    return Status::PENDING if pending?
    return Status::RECERTIFY
  end
end
