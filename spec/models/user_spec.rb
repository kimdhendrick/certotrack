require 'spec_helper'

describe User do
  let(:user) { build(:user) }

  subject { user }

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :email }
  it { should validate_presence_of :username }
  it { should validate_presence_of :customer }
  it { should respond_to(:encrypted_password) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should belong_to(:customer) }

  describe 'associations' do
    it 'should respond to certification_types' do
      user = create(:user, username: 'ABC')
      certification_type = create(:certification_type, customer: user.customer)

      user.certification_types.should == [certification_type]
    end

    it 'should respond to employees' do
      user = create(:user, username: 'ABC')
      employee = create(:employee, customer: user.customer)

      user.employees.should == [employee]
    end

    it 'should respond to equipments' do
      user = create(:user, username: 'ABC')
      equipment = create(:equipment, customer: user.customer)

      user.equipments.should == [equipment]
    end

    it 'should respond to certifications' do
      user = create(:user, username: 'ABC')
      certification = create(:certification, customer: user.customer)

      user.certifications.should == [certification]
    end

    it 'should respond to locations' do
      user = create(:user, username: 'ABC')
      location = create(:location, customer: user.customer)

      user.locations.should == [location]
    end
  end

  describe 'when username has mixed case' do
    let(:user) { create(:user, username: 'ABC') }

    it 'should lowercase the username' do
      user.username.should == 'abc'
    end
  end

  describe 'when email has mixed case' do
    let(:user) { create(:user, email: 'ABC@EMAIL.COM') }

    it 'should lowercase the email' do
      user.email.should == 'abc@email.com'
    end
  end

  describe 'when email format is invalid' do
    it 'should be invalid' do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end
  end

  describe 'when email format is valid' do
    it 'should be valid' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end
  end

  describe 'when email address is already taken' do
    before do
      user_with_same_email = user.dup
      user_with_same_email.email = user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe 'when username is already taken' do
    before do
      user_with_same_username = user.dup
      user_with_same_username.username = user.username.upcase
      user_with_same_username.save
    end

    it { should_not be_valid }
  end

  describe 'when password is not present' do
    before do
      user.password = ''
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { user.password_confirmation = 'mismatch' }
    it { should_not be_valid }
  end

  describe 'when password is not complex enough' do
    before do
      user.password = 'password'
      user.password_confirmation = 'password'
    end
    it { should_not be_valid }
  end

  describe 'when password is complex enough' do
    before do
      user.password = 'Passwor1'
      user.password_confirmation = 'Passwor1'
    end
    it { should be_valid }
  end

  describe 'customer' do
    it 'should be able to assign a customer to a user' do
      customer = build(:customer)
      user = build(:user)
      user.customer = customer

      user.customer.should == customer
    end
  end

  describe 'roles' do
    describe 'roles' do
      it 'should assign and return the roles assigned to the user' do
        user.roles = ['equipment', 'admin']
        user.roles.should =~ ['equipment', 'admin']
      end
    end

    describe 'role?' do
      it 'should return true for roles it has' do
        equipment_user = create(:user, roles: ['equipment'])
        equipment_user.role?('equipment').should be_true
        equipment_user.role?('certification').should be_false
        equipment_user.role?('vehicle').should be_false
        equipment_user.role?('admin').should be_false

        certification_user = create(:user, roles: ['certification'])
        certification_user.role?('equipment').should be_false
        certification_user.role?('certification').should be_true
        certification_user.role?('vehicle').should be_false
        certification_user.role?('admin').should be_false

        vehicle_user = create(:user, roles: ['vehicle'])
        vehicle_user.role?('equipment').should be_false
        vehicle_user.role?('certification').should be_false
        vehicle_user.role?('vehicle').should be_true
        vehicle_user.role?('admin').should be_false

        admin_user = create(:user, roles: ['admin'])
        admin_user.role?('equipment').should be_false
        admin_user.role?('certification').should be_false
        admin_user.role?('vehicle').should be_false
        admin_user.role?('admin').should be_true
      end
    end

    describe 'admin?' do
      it 'should be admin with the admin role' do
        admin_user = create(:user, roles: ['admin'])
        admin_user.should be_admin
      end
    end

    describe 'with_role' do
      it 'should return users with given role' do
        equipment_user_1 = create(:user, roles: ['admin'])
        equipment_user_2 = create(:user, roles: ['admin'])
        certification_user = create(:user, roles: ['certification'])

        User.with_role('admin').should =~ [equipment_user_1, equipment_user_2]
      end
    end
  end

  it 'should respond to its sort_key' do
    user = build(:user, first_name: 'John', last_name: 'Doe')
    user.sort_key.should == 'DoeJohn'
  end
end