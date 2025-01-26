# Load achievements if none exist
Achievement.seed_achievements if Achievement.count.zero?

# Load sample leaderboard data if in development
if Rails.env.development?
  require_relative 'seeds/leaderboard'
end