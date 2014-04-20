require 'spec_helper'
require 'rake'

describe 'password_expiration' do
  before :all do
    load File.expand_path('../../../../Rakefile', __FILE__)
  end

  before do
    task.reenable
  end

  describe 'expire:passwords' do
    let(:task) { Rake::Task['expire:passwords'] }

    it 'should call PasswordExpirationService' do
      password_expiration_service = double('PasswordExpirationService')
      PasswordExpirationService.stub(:new).and_return(password_expiration_service)
      password_expiration_service.should_receive(:execute).at_least(1).times

      task.invoke
    end
  end
end