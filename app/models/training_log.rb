class TrainingLog < ApplicationRecord
  belongs_to :monster

  validates :drill_type, presence: true
  validates :tiredness_before, :tiredness_after,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: Monster::MAX_TIREDNESS }

  # Returns success rate for specific drill
  def self.success_rate_for_drill(drill_type)
    where(drill_type: drill_type).average("CASE WHEN success THEN 1 ELSE 0 END")
  end

  # Returns most successful drill type
  def self.most_successful_drill
    group(:drill_type)
      .select("drill_type, COUNT(*) as total, SUM(CASE WHEN success THEN 1 ELSE 0 END) as successes")
      .order("successes DESC")
      .first
  end
end
