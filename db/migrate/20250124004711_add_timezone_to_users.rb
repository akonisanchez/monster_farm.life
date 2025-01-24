class AddTimezoneToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :timezone, :string, default: 'UTC', null: false
  end
end