class Employee < ActiveRecord::Base

  belongs_to :customer

  def to_s
    "#{last_name}, #{first_name}"
  end
end
