module ObjectMother

  def create_user(options = {})
    FactoryGirl.create(:user, options)
  end

  def new_user(options = {})
    FactoryGirl.build(:user, options)
  end

  def create_valid_equipment(options = {})
    new_valid_equipment(options).tap(&:save!)
  end

  def new_valid_equipment(options = {})
    new_equipment(options.merge({expiration_date: Date.today + 61.days}))
  end

  def create_expired_equipment(options = {})
    new_expired_equipment(options).tap(&:save!)
  end

  def new_expired_equipment(options = {})
    new_equipment(options.merge({expiration_date: Date.yesterday}))
  end

  def create_expiring_equipment(options = {})
    new_expiring_equipment(options).tap(&:save!)
  end

  def new_expiring_equipment(options = {})
    new_equipment(options.merge({expiration_date: Date.tomorrow}))
  end

  def create_noninspectable_equipment(options = {})
    new_noninspectable_equipment(options).tap(&:save!)
  end

  def new_noninspectable_equipment(options = {})
    new_equipment(options.merge({inspection_interval: Interval::NOT_REQUIRED.text, last_inspection_date: nil}))
  end

  def create_equipment(options = {})
    FactoryGirl.create(:equipment, options)
  end

  def new_equipment(options = {})
    FactoryGirl.build(:equipment, options)
  end

  def create_customer(options = {})
    FactoryGirl.create(:customer, options)
  end

  def new_customer(options = {})
    FactoryGirl.build(:customer, options)
  end

  def create_location(options = {})
    FactoryGirl.create(:location, options)
  end

  def new_location(options = {})
    FactoryGirl.build(:location, options)
  end

  def create_employee(options = {})
    FactoryGirl.create(:employee, options)
  end

  def new_employee(options = {})
    FactoryGirl.build(:employee, options)
  end

  def create_certification_type(options = {})
    FactoryGirl.create(:certification_type, options)
  end

  def new_certification_type(options = {})
    FactoryGirl.build(:certification_type, options)
  end

  def create_certification_period(options = {})
    FactoryGirl.create(:certification_period, options)
  end

  def new_certification_period(options = {})
    FactoryGirl.build(:certification_period, options)
  end

  def create_certification(options = {})
    FactoryGirl.create(:certification, options)
  end

  def new_certification(options = {})
    FactoryGirl.build(:certification, options)
  end
end