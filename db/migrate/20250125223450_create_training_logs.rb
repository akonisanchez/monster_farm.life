class CreateTrainingLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :training_logs do |t|
      t.references :monster, null: false, foreign_key: true
      t.string :drill_type
      t.boolean :success
      t.integer :stat_increase
      t.boolean :time_bonus_applied
      t.integer :tiredness_before
      t.integer :tiredness_after

      t.timestamps
    end
  end
end
