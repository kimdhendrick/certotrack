class Customer < ActiveRecord::Base

  has_many :users
  has_many :equipments
  has_many :certification_types
  has_many :certifications
  has_many :employees
  has_many :locations
  has_many :vehicles

  def sort_key
    name
  end
end
