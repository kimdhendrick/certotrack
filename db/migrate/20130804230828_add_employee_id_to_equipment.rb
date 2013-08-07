class AddEmployeeIdToEquipment < ActiveRecord::Migration
  def change
     add_column :equipment, :employee_id, :integer
  end
end
