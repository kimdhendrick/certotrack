class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,99}/

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable

  belongs_to :customer

  validates_presence_of :first_name,
                        :last_name,
                        :customer

  validates :password,
            format: {
              with: VALID_PASSWORD_REGEX,
              message: "must be at least 8 characters long and must contain at least one digit and combination of upper and lower case"
            }
  validates_confirmation_of :password

  validates :email,
            presence: true,
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  validates :username, presence: true, uniqueness: {case_sensitive: false}

  scope :with_role, ->(role) { where(UserRoleHelper::role_where_clause(role)) }

  def admin?
    UserRoleHelper::admin?(self)
  end

  def role?(role)
    UserRoleHelper::role?(self, role)
  end

  def roles=(roles)
    UserRoleHelper::set_roles(self, roles)
  end

  def roles
    UserRoleHelper::roles(self)
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

  def sort_key
    last_name + first_name
  end
end