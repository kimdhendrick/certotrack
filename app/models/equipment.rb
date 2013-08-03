class Equipment < ActiveRecord::Base

  belongs_to :customer
  validates :inspection_type, inclusion: {in: %w(Inspectable Non-Inspectable),
                                          message: 'invalid value'}

  def self.accessible_parameters
    [
      :name,
      :serial_number,
      :inspection_interval,
      :last_inspection_date,
      :inspection_type,
      :notes
    ]
  end

  def status
    return Status::NA if !expiration_date.present?
    return Status::EXPIRED if expiration_date <= Date.today
    return Status::EXPIRING if (expiration_date < Date.today + 60.days)
    Status::VALID
  end

  def expired?
    status == Status::EXPIRED
  end

  def expiring?
    status == Status::EXPIRING
  end
end
