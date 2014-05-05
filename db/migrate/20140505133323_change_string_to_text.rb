class ChangeStringToText < ActiveRecord::Migration
  def change
    change_column :certification_periods, :trainer, :text, :limit => nil
    change_column :certification_periods, :comments, :text, :limit => nil

    change_column :certification_types, :name, :text, :limit => nil
    change_column :certification_types, :interval, :text, :limit => nil
    change_column :certification_types, :created_by, :text, :limit => nil

    change_column :certifications, :created_by, :text, :limit => nil

    change_column :customers, :name, :text, :limit => nil
    change_column :customers, :contact_person_name, :text, :limit => nil
    change_column :customers, :contact_phone_number, :text, :limit => nil
    change_column :customers, :contact_email, :text, :limit => nil
    change_column :customers, :account_number, :text, :limit => nil
    change_column :customers, :address1, :text, :limit => nil
    change_column :customers, :address2, :text, :limit => nil
    change_column :customers, :city, :text, :limit => nil
    change_column :customers, :state, :text, :limit => nil
    change_column :customers, :zip, :text, :limit => nil

    change_column :employees, :first_name, :text, :limit => nil
    change_column :employees, :last_name, :text, :limit => nil
    change_column :employees, :employee_number, :text, :limit => nil
    change_column :employees, :created_by, :text, :limit => nil

    change_column :equipment, :serial_number, :text, :limit => nil
    change_column :equipment, :inspection_interval, :text, :limit => nil
    change_column :equipment, :name, :text, :limit => nil
    change_column :equipment, :comments, :text, :limit => nil
    change_column :equipment, :created_by, :text, :limit => nil

    change_column :locations, :name, :text, :limit => nil
    change_column :locations, :created_by, :text, :limit => nil

    change_column :old_passwords, :encrypted_password, :text, :limit => nil
    change_column :old_passwords, :password_salt, :text, :limit => nil
    change_column :old_passwords, :password_archivable_type, :text, :limit => nil

    change_column :service_periods, :comments, :text, :limit => nil

    change_column :service_types, :name, :text, :limit => nil
    change_column :service_types, :expiration_type, :text, :limit => nil
    change_column :service_types, :interval_date, :text, :limit => nil
    change_column :service_types, :created_by, :text, :limit => nil

    change_column :services, :created_by, :text, :limit => nil

    change_column :users, :first_name, :text, :limit => nil
    change_column :users, :last_name, :text, :limit => nil
    change_column :users, :email, :text, :limit => nil
    change_column :users, :username, :text, :limit => nil
    change_column :users, :encrypted_password, :text, :limit => nil
    change_column :users, :current_sign_in_ip, :text, :limit => nil
    change_column :users, :last_sign_in_ip, :text, :limit => nil
    change_column :users, :expiration_notification_interval, :text, :limit => nil

    change_column :vehicles, :vehicle_number, :text, :limit => nil
    change_column :vehicles, :vin, :text, :limit => nil
    change_column :vehicles, :make, :text, :limit => nil
    change_column :vehicles, :vehicle_model, :text, :limit => nil
    change_column :vehicles, :license_plate, :text, :limit => nil
    change_column :vehicles, :created_by, :text, :limit => nil
  end
end
