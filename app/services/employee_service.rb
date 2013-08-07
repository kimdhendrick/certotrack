module EmployeeService

  def self.get_all_employees(current_user)
    if (current_user.admin?)
      Employee.all
    else
      Employee.where(customer: current_user.customer)
    end
  end
end