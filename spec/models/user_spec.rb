require 'spec_helper'

describe User do
  before { @user = new_valid_user }

  subject { @user }

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :email }
  it { should validate_presence_of :username }
  it { should respond_to(:encrypted_password) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  describe 'when username has mixed case' do
    before do
      @user = create_valid_user(username: 'ABC')
    end
    it 'should lowercase the username' do
      @user.username.should == 'abc'
    end
  end

  describe 'when email has mixed case' do
    before do
      @user = create_valid_user(email: 'ABC@EMAIL.COM')
    end
    it 'should lowercase the email' do
      @user.email.should == 'abc@email.com'
    end
  end

  describe 'when email format is invalid' do
    it 'should be invalid' do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe 'when email format is valid' do
    it 'should be valid' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe 'when email address is already taken' do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe 'when username is already taken' do
    before do
      user_with_same_username = @user.dup
      user_with_same_username.username = @user.username.upcase
      user_with_same_username.save
    end

    it { should_not be_valid }
  end

  describe 'when password is not present' do
    before do
      @user = new_valid_user(password: '')
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = 'mismatch' }
    it { should_not be_valid }
  end

  describe "when password is not complex enough" do
    before do
      @user.password = 'password'
      @user.password_confirmation = 'password'
    end
    it { should_not be_valid }
  end

  describe "when password is complex enough" do
    before do
      @user.password = 'Passwor1'
      @user.password_confirmation = 'Passwor1'
    end
    it { should be_valid }
  end
end
