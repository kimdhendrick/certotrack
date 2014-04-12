module Export
  module EmployeeHeaderColumnMapping
    HEADERS = 'Employee Number,First Name,Last Name,Location,Created By User,Created Date'.split(',')
    COLUMNS = [:employee_number, :first_name, :last_name, :location_name, :created_by, :created_at]
  end
end