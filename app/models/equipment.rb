class Equipment < ActiveRecord::Base

  belongs_to :customer
  belongs_to :location
  belongs_to :employee

  validates_presence_of :name, :serial_number
  validates :last_inspection_date, presence: true, if: :inspectable?
  validates :inspection_interval, inclusion: {in: InspectionInterval.all.map(&:text),
                                              message: 'invalid value'}
  validates_uniqueness_of :serial_number, scope: :customer_id

  def status
    return Status::NA if na?
    return Status::EXPIRED if expired?
    return Status::EXPIRING if expiring?
    Status::VALID
  end

  def status_code
    status.sort_order
  end

  def inspection_interval_code
    InspectionInterval.find_by_text(inspection_interval).id
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

  def expires_on
    InspectionInterval.find_by_text(inspection_interval).expires_on(last_inspection_date)
  end

  def inspection_type
    inspectable? ?
      InspectionType::INSPECTABLE.text :
      InspectionType::NON_INSPECTABLE.text
  end

  def inspectable?
    inspection_interval != InspectionInterval::NOT_REQUIRED.text
  end

  def assigned_to_location?
    location.present?
  end

  def assigned_to_employee?
    employee.present?
  end

  def assignee
    assigned_to.try(:to_s) || "Unassigned"
  end

  def assigned_to
    assigned_to_location? ? location :
      assigned_to_employee? ? employee :
        nil
  end
end
