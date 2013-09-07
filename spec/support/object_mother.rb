module ObjectMother

  def create_user(options = {})
    FactoryGirl.create(:user, options)
  end

  def new_user(options = {})
    FactoryGirl.build(:user, options)
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