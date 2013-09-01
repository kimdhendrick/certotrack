class CreateCertifications < ActiveRecord::Migration
  def change
    create_table :certifications do |t|
      t.integer :certification_type_id
      t.integer :employee_id
      t.integer :customer_id
      t.boolean :active, default: true
      t.integer :active_certification_period_id

      t.timestamps
    end
  end
end
