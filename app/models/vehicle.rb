class Vehicle < ActiveRecord::Base
  include DeletionPrevention

  belongs_to :location
  belongs_to :customer
  has_many :services

  validates_presence_of :vehicle_number,
                        :vin,
                        :license_plate,
                        :created_by,
                        :customer

  validates_uniqueness_of :vehicle_number, scope: :customer_id, case_sensitive: false
  validates_uniqueness_of :license_plate, scope: :customer_id, case_sensitive: false
  validates_uniqueness_of :vin, scope: :customer_id, case_sensitive: false
  validates_length_of :vin, is: 17

  before_validation :_upcase_vin

  before_destroy :_prevent_deletion_when_services

  def status
    applicable_services = services.map(&:status).reject { |status| status == Status::NA }
    return Status.find(applicable_services.map(&:id).max) || Status::NA
  end

  private

  def _prevent_deletion_when_services
    prevent_deletion_of(
      services,
      'Vehicle has services assigned that you must remove before deleting the vehicle.'
    )
  end

  def _upcase_vin
    self.vin.try(&:upcase!)
  end
end