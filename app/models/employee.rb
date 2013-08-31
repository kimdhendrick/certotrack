class Employee < ActiveRecord::Base

  default_scope { where("active = true") }

  belongs_to :customer
  belongs_to :location

  validates_presence_of :employee_number, :first_name, :last_name

  def to_s
    "#{last_name}, #{first_name}"
  end

  def location_name
    location.try(:to_s) || "Unassigned"
  end
end
