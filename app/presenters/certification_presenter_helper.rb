module CertificationPresenterHelper
  HEADERS = 'Employee,Certification Type,Status,Units Achieved,Last Certification Date,Expiration Date,Trainer,Created By User,Created Date,Comments'.split(',')
  COLUMNS = [:employee_name, :certification_type, :status_text, :units, :last_certification_date, :expiration_date, :trainer, :created_by, :created_at, :comments]
end