class UsersController < ModelController
  include ControllerHelper

  before_filter :load_user_service

  def index
    authorize! :read, :user

    @report_title = 'All Users'
    user_collection = @user_service.get_all_users(current_user)
    @user_count = user_collection.count
    @users = UserListPresenter.new(user_collection).present(params)
  end

  def load_user_service(user_service = UserService.new)
    @user_service ||= user_service
  end
end