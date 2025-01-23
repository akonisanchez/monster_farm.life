# This model defines all possible achievements in the game and their requirements
class Achievement < ApplicationRecord
  # Relationships
  has_many :monster_achievements
  has_many :monsters, through: :monster_achievements

  # Make sure each achievement has a unique name and description
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  # Complete list of all possible achievements and their details
  ACHIEVEMENTS = {
    # First tier achievements - earned at 50 in a stat
    power_apprentice: {
      name: "Power Apprentice",
      description: "Reach 50 power"
    },
    speed_apprentice: {
      name: "Speed Apprentice",
      description: "Reach 50 speed"
    },
    yoga_apprentice: {
      name: "Yoga Apprentice",
      description: "Reach 50 health"
    },
    tank_apprentice: {
      name: "Tank Apprentice",
      description: "Reach 50 defense"
    },

    # Second tier achievements - earned at 200 in a stat
    power_pro: {
      name: "Power Pro",
      description: "Reach 200 power"
    },
    speed_pro: {
      name: "Speed Pro",
      description: "Reach 200 speed"
    },
    yoga_pro: {
      name: "Yoga Pro",
      description: "Reach 200 health"
    },
    tank_pro: {
      name: "Tank Pro",
      description: "Reach 200 defense"
    },

    # Final tier achievements - earned at max stat (999)
    power_prodigy: {
      name: "Power Prodigy",
      description: "Reach maximum power"
    },
    speed_demon: {
      name: "Speed Demon",
      description: "Reach maximum speed"
    },
    indomitable_tank: {
      name: "Indomitable Tank",
      description: "Reach maximum defense"
    },
    nirvanic_yogi: {
      name: "Nirvanic Yogi",
      description: "Reach maximum health"
    },

    # Special achievements earned through various milestones
    hot_streak_master: {
      name: "Hot Streak Master",
      description: "Trigger hot streak 5 times"
    },
    streaker: {
      name: "Streaker",
      description: "Complete 10 successful trainings in a row"
    },
    well_rested: {
      name: "Well Rested",
      description: "Rest your monster 10 times total"
    },
    sleepy_baby: {
      name: "Sleepy Baby",
      description: "Rest your monster 100 total"
    },
    training_expert: {
      name: "Training Expert",
      description: "Complete 100 trainings total"
    }
  }.freeze

  # Creates all achievements in database when game is first set up
  def self.seed_achievements
    ACHIEVEMENTS.each do |_, achievement_data|
      find_or_create_by!(name: achievement_data[:name]) do |achievement|
        achievement.description = achievement_data[:description]
      end
    end
  end
end
