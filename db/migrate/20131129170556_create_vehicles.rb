class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :vehicle_number
      t.string :vin
      t.string :make
      t.string :vehicle_model
      t.string :license_plate
      t.integer :year
      t.integer :mileage
      t.integer :location_id
      t.integer :customer_id
      t.timestamps
    end
  end
end
