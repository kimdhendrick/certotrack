class AddActiveCertificationPeriodIdToCertifications < ActiveRecord::Migration
  def up
    add_column :certifications, :active_certification_period_id, :integer, null: true
    execute <<-SQL
      update certifications
      set active_certification_period_id = (
        select certification_periods.id 
        from certification_periods
        where certification_periods.certification_id = certifications.id
      )
    SQL
    
    change_column :certifications, :active_certification_period_id, :integer, null: false
  end

  def down
    remove_column :certifications, :active_certification_period_id
  end
end
