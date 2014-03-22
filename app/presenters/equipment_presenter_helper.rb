module EquipmentPresenterHelper
  HEADERS = 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created Date,Created By User'.split(',')
  COLUMNS = [:name, :serial_number, :status_text, :inspection_interval, :last_inspection_date, :inspection_type, :expiration_date, :assignee, :created_at, :created_by]
end