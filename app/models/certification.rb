class Certification < ActiveRecord::Base
  include SortableByStatus

  default_scope { where('active = true') }

  belongs_to :certification_type
  belongs_to :employee
  belongs_to :customer
  belongs_to :active_certification_period,
    class_name: 'CertificationPeriod',
    autosave: true,
    dependent: :destroy
  has_many :certification_periods,
    class_name: 'CertificationPeriod',
    autosave: true,
    dependent: :destroy

  validates_uniqueness_of :certification_type_id, scope: :employee_id, message: "already assigned to this Employee. Please update existing Certification."

  validates_presence_of :active_certification_period,
    :certification_type,
    :employee,
    :customer

  delegate :comments, to: :active_certification_period
  delegate :comments=, to: :active_certification_period
  delegate :trainer, to: :active_certification_period
  delegate :trainer=, to: :active_certification_period
  delegate :units_achieved, to: :active_certification_period
  delegate :units_achieved=, to: :active_certification_period

  delegate :name, to: :certification_type
  delegate :interval, to: :certification_type
  delegate :units_required, to: :certification_type
  delegate :units_based?, to: :certification_type

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

  def expired?
    _certification_strategy.status == Status::EXPIRED
  end

  def recertify(attributes)
    self.active_certification_period = CertificationPeriod.new(attributes)
    self.expiration_date = ExpirationCalculator.new.calculate(last_certification_date, Interval.find_by_text(interval))
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