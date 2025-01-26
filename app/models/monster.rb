class Monster < ApplicationRecord
  # Model relationships
  belongs_to :user

  # When a monster is destroyed, also destroy its achievements and logs
  has_many :monster_achievements, dependent: :destroy
  has_many :achievements, through: :monster_achievements
  has_many :training_logs, dependent: :destroy do
    def create_log(attributes = {})
      create(attributes)
    end
  end

  # Before we destroy this monster, nullify active_monster_id if it belongs to this user
  before_destroy :nullify_user_active_monster

  # Maximum limits for monster stats
  MAX_STAT = 999
  MAX_TIREDNESS = 10

  # Model validations
  validates :name, presence: true
  validates :power, :speed, :defense, :health,
            numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_STAT }
  validates :tiredness,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_TIREDNESS }

  # Check achievements after stats change
  after_save :check_achievements

  # Achievement and training progress trackers
  attribute :hot_streak_count, :integer, default: 0
  attribute :successful_trainings_count, :integer, default: 0
  attribute :rest_count, :integer, default: 0
  attribute :consecutive_rests, :integer, default: 0

  # Calculate overall training success rate
  def success_rate
    return 0 if training_logs.empty?
    training_logs.where(success: true).count.to_f / training_logs.count
  end

  # Find most successful training type
  def best_drill_type
    return nil if training_logs.empty?
    training_logs.most_successful_drill&.drill_type
  end

  # Main training method that logs attempts and updates stats
  # rubocop:disable Metrics/MethodLength
  def train(drill_type)
    tiredness_before = tiredness
    result = perform_training(drill_type)

    # Log the training results
    if result.present?
      training_logs.create(
        drill_type: drill_type,
        success: true,
        stat_increase: result.is_a?(Hash) ? result.values.sum : 0,
        time_bonus_applied: calculate_time_bonus(drill_type)[:applies],
        tiredness_before: tiredness_before,
        tiredness_after: tiredness
      )
    else
      training_logs.create(
        drill_type: drill_type,
        success: false,
        stat_increase: 0,
        time_bonus_applied: false,
        tiredness_before: tiredness_before,
        tiredness_after: tiredness
      )
    end

    result
  end
  # rubocop:enable Metrics/MethodLength

  # Rest method to recover from tiredness
  def rest
    return false if tiredness >= MAX_TIREDNESS

    unless tiredness.zero?
      recovery = rand(1..2)
      self.tiredness = [ 0, tiredness - recovery ].max
      self.rest_count += 1
    end

    save
  end

  # Check if monster has reached max tiredness
  def game_over?
    tiredness >= MAX_TIREDNESS
  end

  private

  # === Clean Up Before Destroy: Nullify active_monster_id if it points here ===
  def nullify_user_active_monster
    if user && user.active_monster_id == id
      user.update!(active_monster_id: nil)
    end
  end

  # Core training logic with time bonuses and hot streaks
  # rubocop:disable Metrics/MethodLength
  def perform_training(drill_type)
    return false if tiredness >= MAX_TIREDNESS

    # Start with a 75% base success chance
    time_bonus = calculate_time_bonus(drill_type)
    base_success_chance = 75
    # If on a hot streak, add +10% (capped at 95%). Otherwise, stay at 75%.
    success_chance = hot_streak ? [ base_success_chance + 10, 95 ].min : base_success_chance

    success = rand(100) < success_chance
    old_stats = { power: power, defense: defense, health: health, speed: speed }

    if success
      self.successful_trainings_count += 1
      self.training_streak += 1

      # Calculate and apply any bonuses
      stat_increase = calculate_stat_increase(drill_type)
      stat_increase = (stat_increase * time_bonus[:multiplier]).round if time_bonus[:applies]

      # Update relevant stat based on training type
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

      # Check for hot streak after 5 successful trainings in a row
      if training_streak >= 5
        check_hot_streak
        self.hot_streak_count += 1 if hot_streak
      end

      # If we're currently hot, reduce the remaining number of hot-streak successes
      if hot_streak
        self.hot_streak_bonus -= 1  # treat hot_streak_bonus as “remaining successes”
        end_hot_streak if hot_streak_bonus <= 0
      end

      # 5% chance to feel good for next training
      self.feeling_good = rand(100) < 5 unless feeling_good
      self.tiredness += 1
    else
      reset_streaks
      self.tiredness += 2
    end

    # Save the monster and return stat changes on success, or false on failure
    save && success ? calculate_stat_changes(old_stats) : false
  end
  # rubocop:enable Metrics/MethodLength

  # Achievement checking methods
  def check_achievements
    check_stat_achievements
    check_training_achievements
    check_rest_achievements
  end

  # Check if monster qualifies for stat-based achievements
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

  # Check if monster qualifies for training-based achievements
  def check_training_achievements
    award_achievement(:streaker) if training_streak >= 10
    award_achievement(:training_expert) if successful_trainings_count >= 100
    award_achievement(:hot_streak_master) if hot_streak_count >= 5
  end

  # Check if monster qualifies for rest-based achievements
  def check_rest_achievements
    award_achievement(:rest_novice) if rest_count >= 10
    award_achievement(:rest_master) if rest_count >= 100
  end

  # Award achievement if monster doesn't already have it
  def award_achievement(key)
    achievement_data = Achievement::ACHIEVEMENTS[key]
    return unless achievement_data

    achievement = Achievement.find_by(name: achievement_data[:name])
    return if achievement.nil? || monster_achievements.exists?(achievement: achievement)

    monster_achievements.create!(achievement: achievement, earned_at: Time.current)
  end

  # Calculate stat increase including any feeling_good bonus
  def calculate_stat_increase(drill_type)
    base_increase = (drill_type == "meditate" ? rand(1..7) : rand(1..5))

    if feeling_good
      bonus = rand(10..25)
      self.feeling_good = false
      base_increase + bonus
    else
      base_increase
    end
  end

  # Update hot streak status (if not already hot) and set 5 successes remaining
  def check_hot_streak
    return if hot_streak

    self.hot_streak = true
    self.hot_streak_bonus = 5 # Number of successful trainings allowed before streak ends
  end

  # End the hot streak by reverting to normal mode
  def end_hot_streak
    self.hot_streak = false
    self.hot_streak_bonus = 0
  end

  # Reset all streaks and bonuses if a training fails
  def reset_streaks
    self.training_streak = 0
    end_hot_streak if hot_streak
  end

  # Calculate stat changes from training
  def calculate_stat_changes(old_stats)
    {
      power: power - old_stats[:power],
      defense: defense - old_stats[:defense],
      health: health - old_stats[:health],
      speed: speed - old_stats[:speed]
    }.select { |_, v| v > 0 }
  end

  # Calculate time-based training bonuses based on user's timezone
  # rubocop:disable Metrics/MethodLength
  def calculate_time_bonus(drill_type)
    return { applies: false, multiplier: 1.0 } unless user

    current_hour = Time.current.in_time_zone(user.timezone).hour

    # Define bonus periods throughout the day
    bonus = case current_hour
    when 6..11  # Morning bonus: Power training
              { stat: :power, multiplier: 1.5 }
    when 12..17  # Afternoon bonus: Speed training
              { stat: :speed, multiplier: 1.5 }
    when 18..23  # Evening bonus: Defense training
              { stat: :defense, multiplier: 1.5 }
    else         # Night bonus: Health training
              { stat: :health, multiplier: 1.5 }
    end

    # Map drill types to stats for bonus checking
    stat_map = {
      "sled_pull" => :power,
      "dash"      => :speed,
      "parry"     => :defense,
      "meditate"  => :health
    }

    {
      applies: stat_map[drill_type] == bonus[:stat],
      multiplier: bonus[:multiplier]
    }
  end
  # rubocop:enable Metrics/MethodLength
end
