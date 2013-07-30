class AddCustomerIdToEquipment < ActiveRecord::Migration
  def change
     add_column :equipment, :customer_id, :integer
  end
end
