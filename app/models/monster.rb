class Monster < ApplicationRecord
  belongs_to :user, optional: true
  
  # Maximum values for monster stats
  MAX_STAT = 999
  MAX_TIREDNESS = 10
  
  # Ensure all required fields are present and within valid ranges
  validates :name, presence: true
  validates :power, :speed, :defense, :health,
    numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_STAT }
  validates :tiredness,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_TIREDNESS }

  # This method handles all training activities for the monster
  # rubocop:disable Metrics/MethodLength
  def train(drill_type)
    return false if tiredness >= MAX_TIREDNESS

    # Calculate success chance based on hot streak or use default 85%
    base_success_chance = 85
    success_chance = if hot_streak
      [100 - (hot_streak_bonus * 5), base_success_chance].max
    else
      base_success_chance
    end

    success = rand(100) < success_chance
    old_stats = { power: power, defense: defense, health: health, speed: speed }

    if success
      # Track successful training streak
      self.training_streak += 1
      
      # Calculate how much the stat should increase
      stat_increase = calculate_stat_increase(drill_type)
      
      # Apply the stat increase based on training type
      case drill_type
      when "sled_pull"
        self.power = [power + stat_increase, MAX_STAT].min
      when "parry"
        self.defense = [defense + stat_increase, MAX_STAT].min
      when "meditate"
        self.health = [health + stat_increase, MAX_STAT].min
      when "dash"
        self.speed = [speed + stat_increase, MAX_STAT].min
      end

      # Check if monster achieves hot streak (5+ successful trainings)
      check_hot_streak if training_streak >= 5

      # 5% chance to trigger "feeling good" bonus state
      unless feeling_good
        self.feeling_good = rand(100) < 5
      end

      self.tiredness += 1
    else
      # Reset all streaks and bonuses on failure
      reset_streaks
      self.tiredness += 2
    end

    if save && success
      calculate_stat_changes(old_stats)
    else
      false
    end
  end
  # rubocop:enable Metrics/MethodLength

  # Allows monster to rest and recover from tiredness
  def rest
    return false if tiredness >= MAX_TIREDNESS

    recovery = rand(1..2)
    self.tiredness = [0, tiredness - recovery].max
    reset_streaks
    save
  end

  def game_over?
    tiredness >= MAX_TIREDNESS
  end

  private

  # Calculate total stat increase including any bonuses
  def calculate_stat_increase(drill_type)
    base_increase = drill_type == "meditate" ? rand(1..7) : rand(1..5)

    if feeling_good
      bonus = rand(10..25)
      self.feeling_good = false
      base_increase + bonus
    else
      base_increase
    end
  end

  # Check and update hot streak status
  def check_hot_streak
    unless hot_streak
      self.hot_streak = true
      self.hot_streak_bonus = 0
    end
  end

  # Reset all training streaks and bonuses
  def reset_streaks
    self.training_streak = 0
    self.hot_streak = false
    self.hot_streak_bonus = 0
  end

  # Calculate the changes in stats from training
  def calculate_stat_changes(old_stats)
    {
      power: power - old_stats[:power],
      defense: defense - old_stats[:defense],
      health: health - old_stats[:health],
      speed: speed - old_stats[:speed]
    }.select { |_, v| v > 0 }
  end
end