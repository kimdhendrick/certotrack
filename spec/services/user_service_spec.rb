require 'spec_helper'

describe UserService do
  describe 'get_all_users' do
    let(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    context 'when admin user' do
      it 'should return all users' do
        admin_user = create(:user, admin: true)

        users = subject.get_all_users(admin_user)

        users.should =~ [user1, user2, admin_user]
      end
    end

    context 'when regular user' do
      it 'should return nada' do
        user = create(:user)

        users = subject.get_all_users(user)

        users.should be_nil
      end
    end
  end
end