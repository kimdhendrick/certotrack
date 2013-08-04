class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,99}/

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable

  belongs_to :customer

  validates_presence_of :first_name, :last_name

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

  ROLES = %w[admin equipment certification vehicle]

  scope :with_role, ->(role) { where("roles_mask & #{2**ROLES.index(role.to_s)} > 0") }

  def admin?
    role?('admin')
  end

  def role?(role)
    roles.include?(role)
  end

  def role_symbols
    roles.map(&:to_sym)
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |role| _role_mask(role) }.sum
  end

  def roles
    ROLES.reject { |role| ((roles_mask || 0) & _role_mask(role)).zero? }
  end

  def add_role(role)
    return if role?(role)

    self.roles_mask = (self.roles_mask || 0) + _role_mask(role)
  end

  def remove_role(role)
    return if !role?(role)

    self.roles_mask -= _role_mask(role)
  end

  private

  def _role_mask(role)
    2**ROLES.index(role)
  end

end