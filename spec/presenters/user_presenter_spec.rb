require 'spec_helper'

describe UserPresenter do

  let(:user) { build(:user, username: 'user1', first_name: 'Bob', last_name: 'Smith') }

  it 'should respond to model' do
    UserPresenter.new(user).model.should == user
  end

  it 'should respond to id' do
    UserPresenter.new(user).id.should == user.id
  end

  it 'should respond to username' do
    UserPresenter.new(user).username.should == 'user1'
  end

  it 'should respond to first name' do
    UserPresenter.new(user).first_name.should == 'Bob'
  end

  it 'should respond to first name' do
    UserPresenter.new(user).last_name.should == 'Smith'
  end

  it 'should respond to sort_key' do
    UserPresenter.new(user).sort_key.should == 'user1'
  end
end