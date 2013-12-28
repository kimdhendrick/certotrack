class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :service_type_id
      t.integer :vehicle_id
      t.integer :customer_id
      t.integer :active_service_period_id

      t.timestamps
    end
  end
end
