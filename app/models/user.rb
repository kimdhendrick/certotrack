class User < ActiveRecord::Base
  before_save { self.email = email.downcase }

  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation

  validates_presence_of :first_name, :last_name
  validates :password, length: { minimum: 6 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
              presence: true,
              format: { with: VALID_EMAIL_REGEX },
              uniqueness: { case_sensitive: false }

  has_secure_password
end
