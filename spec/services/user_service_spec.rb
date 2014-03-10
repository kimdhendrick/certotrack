require 'spec_helper'

describe UserService do
  describe '#get_all_users' do
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

        user = UserService.new.create_user(admin_user, attributes)

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

        user = UserService.new.create_user(admin_user, attributes)

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

        user = UserService.new.create_user(admin_user, attributes)

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

        success = UserService.new.update_user(admin_user, user, attributes)
        success.should be_true

        user.reload
        user.first_name.should == 'Albert'
      end

      it 'should return false if errors' do
        user = create(:user, first_name: 'Joe')
        user.stub(:save).and_return(false)

        success = UserService.new.update_user(admin_user, user, {first_name: 'Bob'})
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

        UserService.new.update_user(admin_user, user, {customer_id: another_customer.id})

        user.reload
        user.equipment_access?.should be_true
        user.certification_access?.should be_true
        user.vehicle_access?.should be_false
      end
    end

    it 'should return if not admin' do
      UserService.new.update_user(create(:user), create(:user), {}).should be_nil
    end
  end
end