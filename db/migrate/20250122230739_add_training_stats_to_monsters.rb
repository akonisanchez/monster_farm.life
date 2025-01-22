class AddTrainingStatsToMonsters < ActiveRecord::Migration[7.0]
  def change
    add_column :monsters, :training_streak, :integer, default: 0
    add_column :monsters, :feeling_good, :boolean, default: false
    add_column :monsters, :hot_streak, :boolean, default: false
    add_column :monsters, :hot_streak_bonus, :integer, default: 0
  end
end