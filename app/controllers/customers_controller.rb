class CustomersController < ModelController
  include ControllerHelper
  include CustomerHelper

  before_filter :load_customer_service

  before_action :_set_customer, only: [:show, :edit, :update]

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
  end

  def index
    authorize! :read, :customer

    @report_title = 'All Customers'
    customer_collection = @customer_service.get_all_customers(current_user)

    respond_to do |format|
      format.html { _render_collection_as_html(customer_collection) }
      format.csv { _render_collection_as_csv(customer_collection, 'customers') }
      format.xls { _render_collection_as_xls(@report_title, 'customers', customer_collection) }
      format.pdf { _render_collection_as_pdf(@report_title, 'customers', customer_collection) }
    end
  end

  def edit
    authorize! :manage, :customer

    _set_states
  end

  def update
    authorize! :manage, :customer

    success = @customer_service.update_customer(@customer, _customer_params)

    if success
      redirect_to @customer, notice: 'Customer was successfully updated.'
    else
      _set_states
      render action: 'edit'
    end
  end

  private

  def _render_collection_as_html(customer_collection)
    @customer_count = customer_collection.count
    @customers = CustomerListPresenter.new(customer_collection).present(params)
  end

  def _set_customer
    @customer = _get_model(Customer)
  end

  def _customer_params
    params.require(:customer).permit(customer_accessible_parameters)
  end
end