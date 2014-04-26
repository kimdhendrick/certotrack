class User < ActiveRecord::Base
  include EmailFormatHelper

  devise :database_authenticatable, :trackable,
         :password_expirable, :password_archivable, :secure_validatable

  belongs_to :customer

  validates_presence_of :first_name,
                        :last_name,
                        :customer

  validates :email,
            presence: true,
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  validates :username, presence: true, uniqueness: {case_sensitive: false}

  validates :expiration_notification_interval,
            inclusion:
              {
                in: %w(Never Daily Weekly),
                message: 'invalid value',
                allow_nil: false
              }

  scope :with_role, ->(role) { where(UserRoleHelper::role_where_clause(role)) }

  def role?(role)
    UserRoleHelper::role?(self, role)
  end

  def roles=(roles)
    UserRoleHelper::set_roles(self, roles)
  end

  def roles
    UserRoleHelper::roles(self)
  end

  def equipment_access?
    role? UserRoleHelper::ROLE_EQUIPMENT
  end

  def certification_access?
    role? UserRoleHelper::ROLE_CERTIFICATION
  end

  def vehicle_access?
    role? UserRoleHelper::ROLE_VEHICLE
  end

  def certification_types
    customer.certification_types
  end

  def employees
    customer.employees
  end

  def equipments
    customer.equipments
  end

  def certifications
    customer.certifications
  end

  def locations
    customer.locations
  end

  def vehicles
    customer.vehicles
  end

  def service_types
    customer.service_types
  end

  def services
    customer.services
  end

  def sort_key
    last_name + first_name
  end
end