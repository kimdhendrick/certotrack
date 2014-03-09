class Customer < ActiveRecord::Base

  has_many :users
  has_many :equipments
  has_many :certification_types
  has_many :certifications
  has_many :employees
  has_many :locations
  has_many :vehicles
  has_many :service_types
  has_many :services

  def sort_key
    name
  end

  def roles
    [:vehicle, :certification, :equipment].map do |access|
      access.to_s if public_send("#{access.to_s}_access?")
    end.compact
  end
end
