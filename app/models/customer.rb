class Customer < ActiveRecord::Base

  has_many :certification_types
  has_many :certifications
  has_many :employees
  has_many :locations
  has_many :equipments
  has_many :users
end
