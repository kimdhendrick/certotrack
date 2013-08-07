class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.integer :location_id
      t.string :employee_number
      t.integer :customer_id
      t.boolean :active, default: true
      t.date :deactivation_date

      t.timestamps
    end
  end
end
