module ObjectMother

  @@identifier = 0

  def create_valid_user(options = {})
    new_valid_user(options).tap(&:save!)
  end

  def new_valid_user(options = {})
    defaults = {
      username: "username_#{_new_id}",
      first_name: 'First',
      last_name: 'Last',
      email: "email#{_new_id}@email.com",
      password: 'Password123',
      password_confirmation: 'Password123'
    }
    _apply(User.new, defaults, options)
  end

  private

    def _new_id
      @@identifier += 1
    end

    def _apply(record, defaults, options)
      options = defaults.merge(options)
      options.each do |key, value|
        record.send("#{key}=", value.is_a?(Proc) ? value.call : value)
      end
      record
    end
end