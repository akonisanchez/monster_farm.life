# This file defines what a Monster is in our game and what it can do.
# Think of it like creating a template for all monsters in the game.
class Monster < ApplicationRecord
    # Maximum values for stats
    MAX_STAT = 999      # Regular stats can go up to 999
    MAX_TIREDNESS = 10  # Tiredness can only go up to 10
  
    # These lines make sure our monster's stats stay within acceptable ranges
    # It's like setting up guardrails to prevent invalid values
    validates :name, presence: true  # Monster must have a name
    validates :power, :speed, :defense, :health, 
      numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_STAT }
    validates :tiredness, 
      numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_TIREDNESS }
      
    # This method handles all training activities
    # It determines if training is successful (85% chance) and updates stats
    def train(drill_type)
      # Can't train if too tired
      return false if tiredness >= MAX_TIREDNESS
      
      # 85% chance of successful training
      success = rand(100) < 85
      
      if success
        # Based on the type of training, improve different stats
        case drill_type
        when "sled_pull"
          self.power = [power + rand(1..5), MAX_STAT].min
        when "parry"
          self.defense = [defense + rand(1..5), MAX_STAT].min
        when "meditate"
          self.health = [health + rand(1..7), MAX_STAT].min
        when "dash"
          self.speed = [speed + rand(1..5), MAX_STAT].min
        end
        self.tiredness += 1  # Get a little tired from training
      else
        self.tiredness += 2  # Get more tired from failing
      end
      
      save  # Save changes to the database
      success  # Return whether training was successful
    end
    
    # This method lets the monster rest to recover from tiredness
    def rest
      return false if tiredness >= MAX_TIREDNESS  # Can't rest if already collapsed
      recovery = rand(1..2)  # Recover 1-2 points of tiredness
      self.tiredness = [0, tiredness - recovery].max  # Can't go below 0 tiredness
      save
    end
  end