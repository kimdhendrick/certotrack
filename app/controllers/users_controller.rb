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
    report_type = 'users'

    respond_to do |format|
      format.html { _render_collection_as_html(user_collection) }
      format.csv { _render_collection_as_csv(report_type, user_collection) }
      format.xls { _render_collection_as_xls(@report_title, report_type, user_collection) }
      format.pdf { _render_collection_as_pdf(@report_title, report_type, user_collection) }
    end
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
      flash[:success] = _success_message(@user, 'created')
      redirect_to customer_user_path(@user)
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
      flash[:success] = _success_message(@user, 'updated')
      redirect_to customer_user_path(@user)
    else
      _set_customers
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, :user
    user_name = "#{@user.last_name}, #{@user.first_name}"
    if @user_service.delete_user(@user)
      flash[:success] = "User '#{user_name}' was successfully deleted."
      redirect_to customer_users_path
    else
      render :show
    end
  end

  private

  def _success_message(user, verb)
    "User '#{UserPresenter.new(user).name}' was successfully #{verb}."
  end

  def _render_collection_as_html(user_collection)
    @user_count = user_collection.count
    @users = UserListPresenter.new(user_collection).present(params)
  end

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