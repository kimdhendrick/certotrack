class RemoveInspectionTypeFromEquipment < ActiveRecord::Migration
  def change
     remove_column :equipment, :inspection_type
  end
end
