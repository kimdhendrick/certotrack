class CreateServiceTypes < ActiveRecord::Migration
  def change
    create_table :service_types do |t|
      t.string :name
      t.string :expiration_type
      t.string :interval_date
      t.integer :interval_mileage
      t.integer :customer_id

      t.timestamps
    end
  end
end
