class User < ActiveRecord::Base
  include EmailFormatHelper

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable

  belongs_to :customer
  has_many :password_histories, dependent: :destroy

  validates_presence_of :first_name,
                        :last_name,
                        :customer

  validate :_valid_password
  validates_confirmation_of :password, on: :create

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

  before_create :_set_password_last_changed

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

  private

  def _set_password_last_changed
    self.password_last_changed = DateTime.now
  end

  def _valid_password
    return if username.nil? || password.nil?

    if _invalid_password_format?(password)
      errors.add(:password, 'must be at least 8 characters long and must contain at least one digit and combination of upper and lower case')
    elsif password.downcase == username.downcase
      errors.add(:password, 'must not be same as username')
    elsif _password_used_recently?
      errors.add(:password, 'must not have been used recently')
    end
  end

  def _password_used_recently?
    password_histories.any? do |historical_password|
      bcrypt = ::BCrypt::Password.new(historical_password.encrypted_password)
      current_encrypted_password = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt.salt)
      current_encrypted_password == historical_password.encrypted_password
    end
  end

  def _invalid_password_format?(password)
    valid_password_format = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,99}/
    valid_password_format.match(password).nil?
  end
end