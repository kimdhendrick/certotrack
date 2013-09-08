class Employee < ActiveRecord::Base

  default_scope { where("active = true") }

  belongs_to :customer
  belongs_to :location
  has_many :certifications
  has_many :equipments

  before_validation :_strip_whitespace

  validates_presence_of :employee_number,
                        :first_name,
                        :last_name,
                        :customer

  validates_uniqueness_of :employee_number, scope: :customer_id, case_sensitive: false

  def to_s
    "#{last_name}, #{first_name}"
  end

  def location_name
    location.try(:to_s) || "Unassigned"
  end

  private

  def _strip_whitespace
    self.employee_number.try(:strip!)
  end
end
