class CreateServicePeriods < ActiveRecord::Migration
  def change
    create_table :service_periods do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.integer :start_mileage
      t.integer :end_mileage
      t.string :comments
      t.integer :service_id

      t.timestamps
    end
  end
end