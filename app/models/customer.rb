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
    [
      UserRoleHelper::ROLE_VEHICLE,
      UserRoleHelper::ROLE_CERTIFICATION,
      UserRoleHelper::ROLE_EQUIPMENT
    ].map { |access| access if public_send("#{access}_access?") }.compact
  end
end
