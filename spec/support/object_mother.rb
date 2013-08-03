module ObjectMother

  @@identifier = 0

  def create_user(options = {})
    new_user(options).tap(&:save!)
  end

  def new_user(options = {})
    valid_attributes = {
      username: "username_#{_new_id}",
      first_name: 'First',
      last_name: 'Last',
      email: "email#{_new_id}@email.com",
      password: 'Password123',
      password_confirmation: 'Password123'
    }
    _apply(User.new, valid_attributes, options)
  end

  def create_valid_equipment(options = {})
    create_equipment(options.merge({expiration_date: Date.today + 61.days}))
  end

  def new_valid_equipment(options = {})
    new_equipment(options.merge({expiration_date: Date.today + 61.days}))
  end

  def create_expired_equipment(options = {})
    create_equipment(options.merge({expiration_date: Date.yesterday}))
  end

  def new_expired_equipment(options = {})
    new_equipment(options.merge({expiration_date: Date.yesterday}))
  end

  def create_expiring_equipment(options = {})
    create_equipment(options.merge({expiration_date: Date.tomorrow}))
  end

  def new_expiring_equipment(options = {})
    new_equipment(options.merge({expiration_date: Date.tomorrow}))
  end

  def create_equipment(options = {})
    new_equipment(options).tap(&:save!)
  end

  def new_equipment(options = {})
    valid_attributes = equipment_attributes
    _apply(Equipment.new, valid_attributes, options)
  end

  def equipment_attributes
    {
      name: 'Meter',
      inspection_type: 'Inspectable'
    }
  end

  def create_customer(options = {})
    new_valid_customer(options).tap(&:save!)
  end

  def new_valid_customer(options = {})
    valid_attributes = {
      name: 'My Customer'
    }
    _apply(Customer.new, valid_attributes, options)
  end

  def valid_session
    {}
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