module Export
  class ExportModelMap
    def initialize(model_class)
      @map = config[model_class]
    end

    def presenter
      map[:presenter]
    end

    def list_presenter
      map[:list_presenter]
    end

    def headers
      map[:headers].split(',')
    end

    def columns
      map[:columns]
    end

    private

    attr_reader :map

    def config
      {
        User => {
          presenter: UserPresenter,
          list_presenter: UserListPresenter,
          headers: 'Username,First Name,Last Name,Email Address,Password Last Changed,Notification Interval,Customer,Created Date',
          columns: [:username, :first_name, :last_name, :email, :password_changed_at, :expiration_notification_interval, :customer_name, :created_at],
        },
        Equipment => {
          presenter: EquipmentPresenter,
          list_presenter: EquipmentListPresenter,
          headers: 'Name,Serial Number,Status,Inspection Interval,Last Inspection Date,Inspection Type,Expiration Date,Assignee,Created By User,Created Date',
          columns: [:name, :serial_number, :status_text, :inspection_interval, :last_inspection_date, :inspection_type, :expiration_date, :assignee, :created_by, :created_at],
        },
        Certification => {
          presenter: CertificationPresenter,
          list_presenter: CertificationListPresenter,
          headers: 'Employee,Employee Number,Employee Location,Certification Type,Status,Units Achieved,Last Certification Date,Expiration Date,Trainer,Created By User,Created Date,Comments',
          columns: [:employee_name, :employee_number, :location_name, :certification_type, :status_text, :units, :last_certification_date, :expiration_date, :trainer, :created_by, :created_at, :comments],
        },
        Employee => {
          presenter: EmployeePresenter,
          list_presenter: EmployeeListPresenter,
          headers: 'Employee Number,First Name,Last Name,Location,Created By User,Created Date',
          columns: [:employee_number, :first_name, :last_name, :location_name, :created_by, :created_at],
        },
        Customer => {
          presenter: CustomerPresenter,
          list_presenter: CustomerListPresenter,
          headers: 'Name,Account Number,Contact Person Name,Contact Email,Contact Phone Number,Address 1,Address 2,City,State,Zip,Active,Equipment Access,Certification Access,Vehicle Access,Created Date',
          columns: [:name, :account_number, :contact_person_name, :contact_email, :contact_phone_number, :address1, :address2, :city, :state, :zip, :active, :equipment_access, :certification_access, :vehicle_access, :created_at],
        },
      }
    end
  end
end