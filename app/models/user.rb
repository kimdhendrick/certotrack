class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,99}$/

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  attr_accessible :username, :email, :first_name, :last_name,
                  :password, :password_confirmation, :remember_me

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
end