class Employee < ActiveRecord::Base

  belongs_to :customer
  belongs_to :location

  validates_presence_of :employee_number, :first_name, :last_name

  def to_s
    "#{last_name}, #{first_name}"
  end
end
