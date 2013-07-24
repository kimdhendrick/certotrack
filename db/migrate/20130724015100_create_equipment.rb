class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string :serial_number
      t.date :last_inspection_date
      t.string :inspection_interval
      t.string :name
      t.date :expiration_date
      t.string :inspection_type
      t.string :notes

      t.timestamps
    end
  end
end
