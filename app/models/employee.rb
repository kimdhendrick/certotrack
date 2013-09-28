class Employee < ActiveRecord::Base

  default_scope { where('active = true') }

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

  private

  def _strip_whitespace
    self.employee_number.try(:strip!)
    self.first_name.try(:strip!)
    self.last_name.try(:strip!)
  end
end
