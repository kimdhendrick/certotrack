class UsersController < ModelController
  include ControllerHelper
  include UsersHelper

  before_filter :load_user_service,
                :load_customer_service

  before_action :_set_user, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :read, :user

    @report_title = 'All Users'
    user_collection = @user_service.get_all_users
    @user_count = user_collection.count
    @users = UserListPresenter.new(user_collection).present(params)
  end

  def show
    authorize! :read, :user
  end

  def new
    authorize! :create, :user

    @user = User.new(customer: Customer.find(params[:customer_id]))
  end

  def create
    authorize! :create, :user

    @user = @user_service.create_user(_user_params)

    if @user.persisted?
      redirect_to customer_user_path(@user), notice: 'User was successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
    _set_customers
  end

  def update
    success = @user_service.update_user(@user, _user_params)

    if success
      redirect_to customer_user_path(@user), notice: 'User was successfully updated.'
    else
      _set_customers
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, :user
    user_name = "#{@user.last_name}, #{@user.first_name}"
    if @user_service.delete_user(@user)
      redirect_to customer_users_path, notice: "User '#{user_name}' was successfully deleted."
    else
      render :show
    end
  end

  private

  def _set_customers
    @customers = CustomerListPresenter.new(@customer_service.get_all_customers(current_user)).sort
  end

  def _set_user
    @user = _get_model(User)
  end

  def _user_params
    params.require(:user).permit(user_accessible_parameters)
  end
end