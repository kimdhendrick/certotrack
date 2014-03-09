class UsersController < ModelController
  include ControllerHelper

  before_filter :load_user_service

  before_action :_set_user, only: [:show]

  def index
    authorize! :read, :user

    @report_title = 'All Users'
    user_collection = @user_service.get_all_users(current_user)
    @user_count = user_collection.count
    @users = UserListPresenter.new(user_collection).present(params)
  end

  def show
    authorize! :read, :user

    _set_user
  end

  def load_user_service(user_service = UserService.new)
    @user_service ||= user_service
  end

  private

  def _set_user
    @user = _get_model(User)
  end
end