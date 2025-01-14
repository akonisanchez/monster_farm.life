# This file defines what a Monster is in our game and what it can do
class Monster < ApplicationRecord
    # Maximum values for stats
    MAX_STAT = 999      # Regular stats can go up to 999
    MAX_TIREDNESS = 10  # Tiredness can only go up to 10
  
    # These lines make sure our monster's stats stay within acceptable ranges
    validates :name, presence: true
    validates :power, :speed, :defense, :health,
              numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_STAT }
    validates :tiredness,
              numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_TIREDNESS }
  
    # This method handles all training activities
    def train(drill_type)
      return false if tiredness >= MAX_TIREDNESS
  
      success = rand(100) < 85
  
      if success
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
        self.tiredness += 1
      else
        self.tiredness += 2
      end
  
      save
      success
    end
  
    # This method lets the monster rest to recover from tiredness
    def rest
      return false if tiredness >= MAX_TIREDNESS
  
      recovery = rand(1..2)
      self.tiredness = [0, tiredness - recovery].max
      save
    end
  end