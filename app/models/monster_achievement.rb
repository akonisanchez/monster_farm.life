# This model tracks which monsters have earned which achievements
class MonsterAchievement < ApplicationRecord
  # Relationships
  belongs_to :monster
  belongs_to :achievement

  # Make sure a monster can't earn the same achievement twice
  validates :monster_id, uniqueness: { scope: :achievement_id }
  validates :earned_at, presence: true
end
