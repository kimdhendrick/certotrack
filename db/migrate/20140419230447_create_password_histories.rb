class CreatePasswordHistories < ActiveRecord::Migration
  def change
    create_table :password_histories do |t|
      t.integer :user_id
      t.string :encrypted_password
      t.timestamps
    end
  end
end
