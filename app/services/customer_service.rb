class CustomerService
  def get_all_customers(current_user)
    return unless current_user.admin?

    Customer.all
  end
end