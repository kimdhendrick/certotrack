class CustomerService
  def get_all_customers(current_user)
    return unless current_user.admin?

    Customer.all
  end

  def create_customer(attributes)
    customer = Customer.new(attributes)
    customer.save
    customer
  end

  def update_customer(customer, attributes)
    customer.update(attributes)
    customer.save
  end
end