class RenameNotesToCommentsOnEquipment < ActiveRecord::Migration
  def change
    rename_column :equipment, :notes, :comments
  end
end
