# This migration creates the table that tracks which monsters have earned which achievements
class CreateMonsterAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :monster_achievements do |t|
      t.references :monster, null: false, foreign_key: true      # Which monster earned it
      t.references :achievement, null: false, foreign_key: true  # Which achievement they earned
      t.datetime :earned_at, null: false                        # When they earned it

      t.timestamps
    end
    
    # Make sure a monster can't get the same achievement twice
    add_index :monster_achievements, [:monster_id, :achievement_id], unique: true
  end
end