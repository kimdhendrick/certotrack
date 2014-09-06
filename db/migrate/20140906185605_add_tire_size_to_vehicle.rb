class AddTireSizeToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :tire_size, :text
  end
end
