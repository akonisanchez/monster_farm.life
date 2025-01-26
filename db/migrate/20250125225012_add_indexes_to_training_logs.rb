class AddIndexesToTrainingLogs < ActiveRecord::Migration[7.0]
  def change
    add_index :training_logs, [:monster_id, :created_at]
    add_index :training_logs, [:monster_id, :drill_type]
  end
end