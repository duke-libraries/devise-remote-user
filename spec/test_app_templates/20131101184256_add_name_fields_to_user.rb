class AddNameFieldsToUser < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :nickname
      t.string :display_name
    end
  end
end
