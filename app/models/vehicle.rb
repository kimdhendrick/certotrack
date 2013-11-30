class Vehicle < ActiveRecord::Base

  belongs_to :location
  belongs_to :customer

  validates_presence_of :vehicle_number
  validates_presence_of :vin
  validates_presence_of :license_plate

  validates_uniqueness_of :vehicle_number, scope: :customer_id, case_sensitive: false
  validates_uniqueness_of :license_plate, scope: :customer_id, case_sensitive: false
  validates_uniqueness_of :vin, scope: :customer_id, case_sensitive: false
  validates_length_of :vin, is: 17

  before_validation :_upcase_vin


  def status
    Status::NA
  end

  private

  def _upcase_vin
    self.vin.try(&:upcase!)
  end
end