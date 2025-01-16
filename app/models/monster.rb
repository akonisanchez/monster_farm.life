class Monster < ApplicationRecord
    MAX_STAT = 999
    MAX_TIREDNESS = 10

    validates :name, presence: true
    validates :power, :speed, :defense, :health,
      numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_STAT }
    validates :tiredness,
      numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_TIREDNESS }

    # rubocop:disable Metrics/MethodLength
    def train(drill_type)
      return false if tiredness >= MAX_TIREDNESS

      success = rand(100) < 85
      old_stats = { power: power, defense: defense, health: health, speed: speed }

      if success
        case drill_type
        when "sled_pull"
          self.power = [ power + rand(1..5), MAX_STAT ].min
        when "parry"
          self.defense = [ defense + rand(1..5), MAX_STAT ].min
        when "meditate"
          self.health = [ health + rand(1..7), MAX_STAT ].min
        when "dash"
          self.speed = [ speed + rand(1..5), MAX_STAT ].min
        end
        self.tiredness += 1
      else
        self.tiredness += 2
      end

      if save && success
        # Return stat changes
        {
          power: power - old_stats[:power],
          defense: defense - old_stats[:defense],
          health: health - old_stats[:health],
          speed: speed - old_stats[:speed]
        }.select { |_, v| v > 0 }
      else
        false
      end
    end
    # rubocop:enable Metrics/MethodLength

    def rest
      return false if tiredness >= MAX_TIREDNESS
      recovery = rand(1..2)
      self.tiredness = [ 0, tiredness - recovery ].max
      save
    end

    def game_over?
      tiredness >= MAX_TIREDNESS
    end
end
