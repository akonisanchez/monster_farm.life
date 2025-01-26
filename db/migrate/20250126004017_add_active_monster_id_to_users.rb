class AddActiveMonsterIdToUsers < ActiveRecord::Migration[6.1]
    def change
      add_column :users, :active_monster_id, :integer
      add_foreign_key :users, :monsters, column: :active_monster_id
      add_index :users, :active_monster_id
    end
  end
  