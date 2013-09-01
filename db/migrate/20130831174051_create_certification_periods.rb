class CreateCertificationPeriods < ActiveRecord::Migration
  def change
    create_table :certification_periods do |t|
      t.string :trainer
      t.datetime :start_date
      t.datetime :end_date
      t.integer :units_achieved
      t.string :comments
      t.integer :certification_id

      t.timestamps
    end
  end
end
