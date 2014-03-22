class AddCreatedByToTables < ActiveRecord::Migration
  def up
    [
      :certification_types,
      :certifications,
      :employees,
      :equipment,
      :locations,
      :service_types,
      :services,
      :vehicles
    ].each do |table|
      add_column table, :created_by, :string
    end
  end

  def down
    [
      :certification_types,
      :certifications,
      :employees,
      :equipment,
      :locations,
      :service_types,
      :services,
      :vehicles
    ].each do |table|
      remove_column table, :created_by, :string
    end
  end
end
