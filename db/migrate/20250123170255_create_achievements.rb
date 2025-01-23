# This migration creates the table that stores all possible achievements in the game
class CreateAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :achievements do |t|
      t.string :name, null: false      # Achievement title (e.g., "Power Apprentice")
      t.string :description, null: false # What player did to earn it
      
      t.timestamps # When achievement was created in database
    end
  end
end