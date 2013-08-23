class CreateCertificationTypes < ActiveRecord::Migration
  def change
    create_table :certification_types do |t|
      t.string :name
      t.string :inspection_interval
      t.integer :units_required
      t.integer :customer_id

      t.timestamps
    end
  end
end
