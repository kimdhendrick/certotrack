class DropActiveCertificationPeriodIdFromCertifications < ActiveRecord::Migration
  def change
    remove_column :certifications, :active_certification_period_id
  end
end
