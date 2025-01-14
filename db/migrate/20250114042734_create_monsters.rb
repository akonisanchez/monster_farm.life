class CreateMonsters < ActiveRecord::Migration[8.0]
  def change
    create_table :monsters do |t|
      t.string :name
      t.integer :power
      t.integer :speed
      t.integer :defense
      t.integer :health
      t.integer :tiredness

      t.timestamps
    end
  end
end
