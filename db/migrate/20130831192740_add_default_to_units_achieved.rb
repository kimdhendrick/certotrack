class AddDefaultToUnitsAchieved < ActiveRecord::Migration
  def change
    change_column :certification_periods, :units_achieved, :integer, default: 0
  end
end
