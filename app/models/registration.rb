class Registration
  include ActiveModel::Validations
  include ActiveModel::Model

  attr_accessor :first_name,
                :last_name,
                :customer_name,
                :email,
                :subscription,
                :password,
                :password_confirm

  validates_presence_of :first_name, :last_name, :customer_name, :email, :subscription

  validates :subscription,
            inclusion:
                {
                    in: Subscription.all.map(&:text),
                    message: 'invalid value',
                    allow_nil: false
                }

  validate :passwords_match

  def add_errors(attribute, error)
    errors.add(attribute, error)
  end

  private

  def passwords_match
    if password != password_confirm
      errors.add(:password, 'does not match Confirm Password')
    end
  end
end