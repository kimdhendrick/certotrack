class Service < ActiveRecord::Base
  include SortableByStatus

  belongs_to :service_type
  belongs_to :vehicle
  belongs_to :customer
  belongs_to :active_service_period,
             class_name: 'ServicePeriod',
             autosave: true,
             dependent: :destroy
  has_many :service_periods,
           class_name: 'ServicePeriod',
           autosave: true,
           dependent: :destroy

  validates_uniqueness_of :service_type_id, scope: :vehicle_id, message: 'already assigned to this Vehicle. Please update existing Service.'

  validates_presence_of :active_service_period,
                        :service_type,
                        :vehicle,
                        :customer

  validate :_service_period_start_dates

  delegate :comments, to: :active_service_period
  delegate :comments=, to: :active_service_period

  delegate :name, to: :service_type
  delegate :interval_date, to: :service_type
  delegate :interval_mileage, to: :service_type
  delegate :expiration_type, to: :service_type

  def date_expiration_type?
    service_type.try(&:date_expiration_type?)
  end

  def mileage_expiration_type?
    service_type.try(&:mileage_expiration_type?)
  end

  def expiration_date
    active_service_period.end_date
  end

  def expiration_date=(date)
    active_service_period.end_date=(date)
  end

  def expiration_mileage
    active_service_period.end_mileage
  end

  def expiration_mileage=(mileage)
    active_service_period.end_mileage=(mileage)
  end

  def last_service_date
    active_service_period.try(:start_date)
  end

  def last_service_date=(date)
    if active_service_period.present?
      active_service_period.start_date=(date)
    end
  end

  def last_service_mileage
    active_service_period.try(:start_mileage)
  end

  def last_service_mileage=(mileage)
    if active_service_period.present?
      active_service_period.start_mileage=(mileage)
    end
  end

  def status
    _service_strategy.status
  end

  def expired?
    _service_strategy.status == Status::EXPIRED
  end

  def expiring?
    _service_strategy.status == Status::EXPIRING
  end

  def reservice(attributes)
    self.active_service_period = ServicePeriod.new(attributes)
    expiration_calculator = ExpirationCalculator.new
    self.expiration_date = expiration_calculator.calculate(last_service_date, Interval.find_by_text(interval_date))
    self.expiration_mileage = expiration_calculator.calculate_mileage(last_service_mileage, interval_mileage)
  end

  private

  def _service_period_start_dates
    return if last_service_date.nil?

    if service_periods.any? { |service_period| _start_date_before_last_service?(service_period) }
      errors.add(:last_service_date, 'must be after previous Last service date')
    end
  end

  def _start_date_before_last_service?(service_period)
    service_period != active_service_period &&
      service_period.start_date >= active_service_period.start_date
  end

  def _service_strategy
    @service_strategy ||=
      (expiration_type == ServiceType::EXPIRATION_TYPE_BY_DATE ?
        DateBasedServiceStrategy.new(self) :
        MileageBasedServiceStrategy.new(self))
  end

  class ServiceStrategy
    attr_reader :service

    def initialize(service)
      @service = service
    end

    def status
      return Status::NA if _na?
      return Status::EXPIRED if _expired?
      return Status::EXPIRING if _expiring?
      Status::VALID
    end

    private

    def _na?
      !_expiration_value.present?
    end

    def _expiring?
      _expiration_value.present? && !_expired? && _expiring_soon
    end
  end

  class DateBasedServiceStrategy < ServiceStrategy

    private

    def _expiration_value
      service.expiration_date
    end

    def _expiring_soon
      _expiration_value < Date.today + 60.days
    end

    def _expired?
      _expiration_value.present? && _expiration_value <= Date.today
    end
  end

  class MileageBasedServiceStrategy < ServiceStrategy

    private

    def _expiration_value
      service.expiration_mileage
    end

    def _expiring_soon
      _expiration_value < (service.vehicle.mileage + 500)
    end

    def _expired?
      _expiration_value.present? && _expiration_value <= service.vehicle.mileage
    end
  end
end