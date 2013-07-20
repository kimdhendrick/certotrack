module ObjectMother

  def create_valid_user(options = {})
    new_valid_user(options).tap(&:save!)
  end

  def new_valid_user(options = {})
    defaults = {
      username: 'username',
      first_name: 'First',
      last_name: 'Last',
      email: 'email@email.com',
      password: 'password',
      password_confirmation: 'password'
    }
    apply(User.new, defaults, options)
  end

  def apply(record, defaults, options)
    options = defaults.merge(options)
    options.each do |key, value|
      record.send("#{key}=", value.is_a?(Proc) ? value.call : value)
    end
    record
  end
end