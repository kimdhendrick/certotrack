class CustomersController < ModelController
  include CustomerHelper

  before_filter :load_customer_service

  def new
    authorize! :manage, :customer
    _set_states
    @customer = Customer.new
  end

  def create
    authorize! :manage, :customer
    @customer = @customer_service.create_customer(_customer_params)

    if @customer.persisted?
      redirect_to @customer, notice: "Customer '#{@customer.name}' was successfully created."
    else
      _set_states
      render action: 'new'
    end
  end

  def show
    authorize! :manage, :customer
    @customer = Customer.find(params[:id])
  end

  def index
    authorize! :read, :customer

    @report_title = 'All Customers'
    customer_collection = @customer_service.get_all_customers(current_user)
    @customer_count = customer_collection.count
    @customers = CustomerListPresenter.new(customer_collection).present(params)
  end

  def load_customer_service(customer_service = CustomerService.new)
    @customer_service ||= customer_service
  end

  private

  def _customer_params
    params.require(:customer).permit(customer_accessible_parameters)
  end
end