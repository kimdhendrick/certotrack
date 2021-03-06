class Employee < ActiveRecord::Base
  include DeletionPrevention

  default_scope { where('employees.active = true') }

  belongs_to :customer
  belongs_to :location
  has_many :certifications, autosave: true
  has_many :equipments, autosave: true

  before_validation :_strip_whitespace

  validates_presence_of :employee_number,
                        :first_name,
                        :last_name,
                        :customer,
                        :created_by,
                        :location

  validates_uniqueness_of :employee_number, scope: :customer_id, case_sensitive: false

  before_destroy :_prevent_deletion_when_equipment_or_certifications

  default_scope { includes(:location) }

  private

  def _prevent_deletion_when_equipment_or_certifications
    valid = prevent_deletion_of(
      equipments,
      'Employee has equipment assigned, you must remove them before deleting the employee. Or Deactivate the employee instead.'
    )

    valid & prevent_deletion_of(
      certifications,
      'Employee has certifications, you must remove them before deleting the employee. Or Deactivate the employee instead.'
    )
  end

  def _strip_whitespace
    self.employee_number.try(:strip!)
    self.first_name.try(:strip!)
    self.last_name.try(:strip!)
  end
end
