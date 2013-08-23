class RenameInspectionIntervalToIntervalOnCertificationTypes < ActiveRecord::Migration
  def change
    rename_column :certification_types, :inspection_interval, :interval
  end
end
