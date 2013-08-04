class Equipment < ActiveRecord::Base

  belongs_to :customer
  belongs_to :location

  validates :inspection_type, inclusion: {in: InspectionType.all.map(&:text),
                                          message: 'invalid value'}
  validates :inspection_interval, inclusion: {in: InspectionInterval.all.map(&:text),
                                              message: 'invalid value'}

  def self.accessible_parameters
    [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :inspection_type,
      :notes,
      :location_id
    ]
  end

  def status
    return Status::NA if na?
    return Status::EXPIRED if expired?
    return Status::EXPIRING if expiring?
    Status::VALID
  end

  def na?
    !expiration_date.present?
  end

  def expired?
    expiration_date <= Date.today
  end

  def expiring?
    !expired? && expiration_date < Date.today + 60.days
  end

  def expires_on
    InspectionInterval.find_by_text(inspection_interval).expires_on(last_inspection_date)
  end

  def calculate_inspection_type
    inspection_interval == InspectionInterval::NOT_REQUIRED.text ?
      InspectionType::NON_INSPECTABLE.text :
      InspectionType::INSPECTABLE.text
  end
end
