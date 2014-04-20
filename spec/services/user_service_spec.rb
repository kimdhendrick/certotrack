require 'spec_helper'

describe UserService do
  describe '#get_all_users' do
    let(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    context 'when admin user' do
      it 'should return all users' do
        admin_user = create(:user, admin: true)

        users = subject.get_all_users

        users.should =~ [user1, user2, admin_user]
      end
    end
  end

  describe '#create_user' do
    context 'as an admin user' do
      it 'should create user' do
        customer = create(:customer)
        admin_user = create(:user, admin: true)
        attributes =
          {
            'first_name' => 'Adam',
            'last_name' => 'Ant',
            'email' => 'adam@example.com',
            'username' => 'adam',
            'password' => 'Password123',
            'customer_id' => customer.id
          }

        user = UserService.new.create_user(attributes)

        user.should be_persisted
        user.first_name.should == 'Adam'
        user.customer.should == customer
      end

      it 'should create user with correct roles' do
        customer = create(
          :customer,
          equipment_access: true,
          certification_access: true,
          vehicle_access: false
        )
        admin_user = create(:user, admin: true)
        attributes =
          {
            'first_name' => 'Adam',
            'last_name' => 'Ant',
            'email' => 'adam@example.com',
            'username' => 'adam',
            'password' => 'Password123',
            'customer_id' => customer.id
          }

        user = UserService.new.create_user(attributes)

        user.equipment_access?.should be_true
        user.certification_access?.should be_true
        user.vehicle_access?.should be_false
      end

      it 'should return user with errors if user is invalid' do
        customer = create(:customer)
        admin_user = create(:user, admin: true)
        attributes =
          {
            'first_name' => 'Adam',
            'customer_id' => customer.id
          }

        user = UserService.new.create_user(attributes)

        user.should_not be_persisted
        user.errors['last_name'].should == ["can't be blank"]
        user.customer.should == customer
      end
    end
  end

  describe '#update_user' do
    context 'admin user' do
      let(:admin_user) { create(:user, admin: true) }

      it 'should update users attributes' do
        my_customer = create(:customer)
        user = create(:user, customer: my_customer)
        attributes =
          {
            'id' => user.id,
            'first_name' => 'Albert'
          }

        success = UserService.new.update_user(user, attributes)
        success.should be_true

        user.reload
        user.first_name.should == 'Albert'
      end

      it 'should return false if errors' do
        user = create(:user, first_name: 'Joe')
        user.update_attribute(:username, nil)
        user.should_not be_valid

        success = UserService.new.update_user(user, {first_name: 'Bob'})
        success.should be_false

        user.reload
        user.first_name.should_not == 'Bob'
      end

      it 'should update user with correct roles' do
        user = create(:user)

        another_customer = create(
          :customer,
          equipment_access: true,
          certification_access: true,
          vehicle_access: false
        )

        UserService.new.update_user(user, {customer_id: another_customer.id})

        user.reload
        user.equipment_access?.should be_true
        user.certification_access?.should be_true
        user.vehicle_access?.should be_false
      end

      context 'updating password' do
        it 'should update password' do
          user = create(
            :user,
            password: 'MyOldPassword123',
            password_confirmation: 'MyOldPassword123'
          )

          attributes =
            {
              'id' => user.id,
              'password' => 'MyNewPassword123'
            }

          UserService.new.update_user(user, attributes)

          user.reload
          user.password.should == 'MyNewPassword123'
        end

        context 'password change' do
          it 'should add to the password histories' do
            user = create(
              :user,
              password: 'MyOldPassword123',
              password_confirmation: 'MyOldPassword123'
            )

            attributes =
              {
                'id' => user.id,
                'password' => 'MyNewPassword123'
              }

            user.password_histories.count.should == 0

            UserService.new.update_user(user, attributes)

            user.reload
            user.password_histories.count.should == 1
          end

          it 'should be valid' do
            user = create(
              :user,
              password: 'MyOldPassword123',
              password_confirmation: 'MyOldPassword123'
            )

            attributes =
              {
                'id' => user.id,
                'password' => 'MyNewPassword123'
              }

            success = UserService.new.update_user(user, attributes)

            success.should be_true
            user.reload

            user.valid?
            puts user.errors.full_messages

            user.should be_valid
          end

          it 'should not update password data if errors' do
            user = create(:user, password_histories: [])
            user.update_attribute(:username, nil)
            user.update_attribute(:password_last_changed, nil)
            user.should_not be_valid
            old_password = user.encrypted_password

            success = UserService.new.update_user(user, {password: 'NewPassword123'})
            success.should be_false

            user.reload
            user.encrypted_password.should == old_password
            user.password_histories.should == []
            user.password_last_changed.should be_nil
          end
        end

        context 'not a password change' do
          it 'should not add to the password histories' do
            user = create(:user)

            attributes =
              {
                'id' => user.id,
                'username' => 'new_username'
              }

            user.password_histories.count.should == 0

            UserService.new.update_user(user, attributes)

            user.reload
            user.password_histories.count.should == 0
          end
        end

        it 'should purge password histories > 5' do
          too_many_password_histories = []
          10.times do |i|
            too_many_password_histories <<
              PasswordHistory.new(
                created_at: Time.now + i.seconds,
                encrypted_password: User.new(password: 'blah').encrypted_password
              )
          end
          oldest = too_many_password_histories[0]
          newest = too_many_password_histories[9]

          oldest.created_at.should < newest.created_at

          user = create(
            :user,
            password: 'MyOldPassword123',
            password_confirmation: 'MyOldPassword123',
            password_histories: too_many_password_histories
          )

          attributes =
            {
              'id' => user.id,
              'password' => 'MyNewPassword123'
            }

          user.password_histories.count.should == 10
          PasswordHistory.count.should == 10

          UserService.new.update_user(user, attributes)

          user.reload
          user.password_histories.count.should == 5
          user.password_histories.should include(newest)
          PasswordHistory.count.should == 5
        end

        it 'should update password_last_changed date' do
          old_date_of_password_change = Date.new(2001, 1, 1)
          user = create(
            :user,
            password: 'MyOldPassword123',
            password_confirmation: 'MyOldPassword123',
            password_last_changed: old_date_of_password_change
          )

          attributes =
            {
              'id' => user.id,
              'password' => 'MyNewPassword123'
            }

          UserService.new.update_user(user, attributes)

          user.reload
          user.password_last_changed.should > old_date_of_password_change
        end

        context 'not a password change' do
          it 'should not update password_last_changed date' do
            user = create(:user)
            old_date_of_password_change = user.password_last_changed

            attributes =
              {
                'id' => user.id,
                'username' => 'new_username'
              }

            UserService.new.update_user(user, attributes)

            user.reload
            (user.password_last_changed - old_date_of_password_change).should == 0
          end
        end
      end
    end
  end

  describe '#delete_user' do
    it 'destroys the requested user' do
      user = create(:user)
      user.password_histories << PasswordHistory.create

      PasswordHistory.count.should == 1

      expect {
        UserService.new.delete_user(user)
      }.to change(User, :count).by(-1)

      PasswordHistory.count.should == 0
    end
  end
end