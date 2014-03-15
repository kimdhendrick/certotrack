class CustomerService
  def get_all_customers(current_user)
    Customer.all if current_user.admin?
  end

  def create_customer(attributes)
    customer = Customer.new(attributes)
    customer.save
    customer
  end

  def update_customer(customer, attributes)
    customer.update(attributes)
    customer.users.each { |user| user.roles = customer.roles }
    customer.save
  end
end