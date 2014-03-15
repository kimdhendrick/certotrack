class Customer < ActiveRecord::Base
  include EmailFormatHelper

  has_many :users
  has_many :equipments
  has_many :certification_types
  has_many :certifications
  has_many :employees
  has_many :locations
  has_many :vehicles
  has_many :service_types
  has_many :services

  validates_presence_of :name,
                        :contact_person_name

  validates_uniqueness_of :account_number

  validates :contact_email,
            presence: true,
            format: {with: VALID_EMAIL_REGEX}
  before_validation :_downcase_contact_email

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

  private

  def _downcase_contact_email
    self.contact_email.try(:downcase!)
  end
end
