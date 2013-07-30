class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.string :contact_person_name
      t.string :contact_phone_number
      t.string :contact_email
      t.string :account_number
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.boolean :active
      t.boolean :notification
      t.boolean :equipment_access
      t.boolean :certification_access
      t.boolean :vehicle_access

      t.timestamps
    end
  end
end
