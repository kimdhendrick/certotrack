class Location < ActiveRecord::Base
  include DeletionPrevention

  belongs_to :customer
  has_many :equipments
  has_many :employees
  has_many :vehicles

  before_validation :_strip_whitespace

  validates_presence_of :name,
                        :customer,
                        :created_by
  validates_uniqueness_of :name, scope: :customer_id, case_sensitive: false

  before_destroy :_prevent_deletion_when_equipment_or_employees

  def to_s
    name
  end

  def sort_key
    name
  end

  private

  def _prevent_deletion_when_equipment_or_employees
    valid = prevent_deletion_of(
      equipments,
      'Location has equipment assigned, you must reassign them before deleting the location.'
    )
    valid = valid & prevent_deletion_of(
      employees,
      'Location has employees assigned, you must reassign them before deleting the location.'
    )

    valid & prevent_deletion_of(
      vehicles,
      'Location has vehicles assigned, you must reassign them before deleting the location.'
    )
  end

  def _strip_whitespace
    self.name.try(:strip!)
  end

end
