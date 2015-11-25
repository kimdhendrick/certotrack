class Registration
  include ActiveModel::Validations
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :customer_name, :email, :subscription

  validates_presence_of :first_name, :last_name, :customer_name, :email, :subscription

  validates :subscription,
            inclusion:
                {
                    in: Subscription.all.map(&:text),
                    message: 'invalid value',
                    allow_nil: false
                }

  def add_errors(attribute, error)
    errors.add(attribute, error)
  end
end