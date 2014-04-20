require 'spec_helper'

describe PasswordExpirationService do
  describe 'execute' do
    it 'should expire passwords without a password_last_changed date' do
      user = create(:user, password_expired: false)

      PasswordExpirationService.new.execute

      user.reload
      user.password_expired.should be_true
    end

    it 'should not modify passwords already expired' do
      user = create(:user, password_last_changed: Date.new(2010, 1, 1), password_expired: true)

      PasswordExpirationService.new.execute

      user.reload
      user.password_expired.should be_true
    end

    it 'should expire passwords older than 90 days' do
      user = create(:user, password_last_changed: Date.new(2010, 1, 1), password_expired: false)

      PasswordExpirationService.new.execute

      user.reload
      user.password_expired.should be_true
    end

    it 'should not expire current passwords' do
      user = create(:user, password_last_changed: Date.yesterday, password_expired: false)

      PasswordExpirationService.new.execute

      user.reload
      user.password_expired.should be_false
    end
  end
end
