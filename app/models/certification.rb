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

  def name
    certification_type.name
  end

  def units_required
    certification_type.units_required
  end

  def units_based?
    certification_type.units_based?
  end

  def expiration_date
    active_certification_period.end_date
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
    _certification_strategy.status
  end

  def sort_key
    name
  end

  private

  def _certification_strategy
    @certification_strategy ||= units_based? ? UnitsBasedCertificationStrategy.new(self) : DateBasedCertificationStrategy.new(self)
  end

  class CertificationStrategy
    attr_reader :certification

    def initialize(certification)
      @certification = certification
    end

    def status
      raise NotImplementedError
    end

    private

    def _expired?
      _expiration_date.present? && _expiration_date <= Date.today
    end

    def _expiration_date
      certification.expiration_date
    end
  end

  class UnitsBasedCertificationStrategy < CertificationStrategy

    def status
      return Status::VALID if _achieved_units_required?
      return Status::PENDING if _pending?
      return Status::RECERTIFY
    end

    private

    def _achieved_units_required?
      (certification.units_achieved || 0) >= _units_required
    end

    def _pending?
      _expiration_date.present? && !_expired? && !_achieved_units_required?
    end

    def _units_required
      certification.certification_type.units_required
    end
  end

  class DateBasedCertificationStrategy < CertificationStrategy

    def status
      return Status::NA if _na?
      return Status::EXPIRED if _expired?
      return Status::EXPIRING if _expiring?
      Status::VALID
    end

    private

    def _na?
      !_expiration_date.present?
    end

    def _expiring?
      _expiration_date.present? && !_expired? && _expiration_date < Date.today + 60.days
    end
  end
end

