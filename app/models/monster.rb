class Monster < ApplicationRecord
  belongs_to :user, optional: true
  has_many :monster_achievements, dependent: :destroy
  has_many :achievements, through: :monster_achievements

  MAX_STAT = 999
  MAX_TIREDNESS = 10

  validates :name, presence: true
  validates :power, :speed, :defense, :health,
    numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_STAT }
  validates :tiredness,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_TIREDNESS }

  after_save :check_achievements

  # Track achievement progress
  attribute :hot_streak_count, :integer, default: 0
  attribute :successful_trainings_count, :integer, default: 0
  attribute :rest_count, :integer, default: 0
  attribute :consecutive_rests, :integer, default: 0

  # rubocop:disable Metrics/MethodLength
  def train(drill_type)
    return false if tiredness >= MAX_TIREDNESS

    # Calculate success chance
    base_success_chance = 85
    success_chance = if hot_streak
      [ 100 - (hot_streak_bonus * 5), base_success_chance ].max
    else
      base_success_chance
    end

    success = rand(100) < success_chance
    old_stats = { power: power, defense: defense, health: health, speed: speed }

    if success
      # Track training success
      self.successful_trainings_count += 1
      self.training_streak += 1

      # Calculate and apply stat increase
      stat_increase = calculate_stat_increase(drill_type)

      case drill_type
      when "sled_pull"
        self.power = [ power + stat_increase, MAX_STAT ].min
      when "parry"
        self.defense = [ defense + stat_increase, MAX_STAT ].min
      when "meditate"
        self.health = [ health + stat_increase, MAX_STAT ].min
      when "dash"
        self.speed = [ speed + stat_increase, MAX_STAT ].min
      end

      # Update streaks
      if training_streak >= 5
        check_hot_streak
        self.hot_streak_count += 1 if hot_streak
      end

      # Check for 5% chance feeling good bonus
      unless feeling_good
        self.feeling_good = rand(100) < 5
      end

      self.tiredness += 1
    else
      reset_streaks
      self.tiredness += 2
    end

    save && success ? calculate_stat_changes(old_stats) : false
  end
  # rubocop:enable Metrics/MethodLength

  def rest
    return false if tiredness >= MAX_TIREDNESS

    if !tiredness.zero?
      recovery = rand(1..2)
      self.tiredness = [ 0, tiredness - recovery ].max
      self.rest_count += 1
    end

    save
  end

  def game_over?
    tiredness >= MAX_TIREDNESS
  end

  private

  def check_achievements
    check_stat_achievements
    check_training_achievements
    check_rest_achievements
  end

  def check_stat_achievements
    stat_thresholds = {
      power: { 50 => :power_apprentice, 200 => :power_pro, 999 => :power_prodigy },
      speed: { 50 => :speed_apprentice, 200 => :speed_pro, 999 => :speed_demon },
      defense: { 50 => :tank_apprentice, 200 => :tank_pro, 999 => :indomitable_tank },
      health: { 50 => :yoga_apprentice, 200 => :yoga_pro, 999 => :nirvanic_yogi }
    }

    stat_thresholds.each do |stat, thresholds|
      thresholds.each do |value, achievement_key|
        award_achievement(achievement_key) if self[stat] >= value
      end
    end
  end

  def check_training_achievements
    award_achievement(:streaker) if training_streak >= 10
    award_achievement(:training_expert) if successful_trainings_count >= 100
    award_achievement(:hot_streak_master) if hot_streak_count >= 5
  end

  def check_rest_achievements
    award_achievement(:well_rested) if rest_count >= 10
    award_achievement(:sleepy_baby) if rest_count >= 100
  end

  def award_achievement(key)
    achievement_data = Achievement::ACHIEVEMENTS[key]
    return unless achievement_data

    achievement = Achievement.find_by(name: achievement_data[:name])
    return if achievement.nil? || monster_achievements.exists?(achievement: achievement)

    monster_achievements.create!(achievement: achievement, earned_at: Time.current)
  end

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

  def check_hot_streak
    unless hot_streak
      self.hot_streak = true
      self.hot_streak_bonus = 0
    end
  end

  def reset_streaks
    self.training_streak = 0
    self.hot_streak = false
    self.hot_streak_bonus = 0
  end

  def calculate_stat_changes(old_stats)
    {
      power: power - old_stats[:power],
      defense: defense - old_stats[:defense],
      health: health - old_stats[:health],
      speed: speed - old_stats[:speed]
    }.select { |_, v| v > 0 }
  end
end
