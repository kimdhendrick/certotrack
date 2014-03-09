class UsersController < ModelController
  include ControllerHelper
  include UsersHelper

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

  def new
    authorize! :create, :user

    @user = User.new(customer: Customer.find(params[:customer_id]))
  end

  def create
    authorize! :create, :user

    @user = @user_service.create_user(current_user, _user_params)

    if @user.persisted?
      redirect_to customer_user_path(@user), notice: 'User was successfully created.'
    else
      render action: 'new'
    end
  end

  def load_user_service(user_service = UserService.new)
    @user_service ||= user_service
  end

  private

  def _set_user
    @user = _get_model(User)
  end

  def _user_params
    params.require(:user).permit(user_accessible_parameters)
  end
end