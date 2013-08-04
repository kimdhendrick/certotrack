class AddLocationIdToEquipment < ActiveRecord::Migration
  def change
     add_column :equipment, :location_id, :integer
  end
end
