class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true,
            uniqueness: { message: "is already taken" },
            length: { minimum: 3, maximum: 20,
                     message: "must be between 3 and 20 characters" }
  validates :password, length: { minimum: 6,
                     message: "must be at least 6 characters long" },
            on: :create

  has_many :monsters, dependent: :destroy

  # Active monster association
  belongs_to :active_monster, class_name: "Monster", optional: true

  # Callbacks
  before_validation :set_default_timezone

  # Scope to order users by total monster stats
  scope :ranked, -> {
    select("users.*,
            COALESCE(SUM(monsters.power),0) +
            COALESCE(SUM(monsters.speed),0) +
            COALESCE(SUM(monsters.defense),0) +
            COALESCE(SUM(monsters.health),0) AS total_stats")
      .left_joins(:monsters)
      .group("users.id")
      .order("total_stats DESC")
  }

  # Calculate user total monster stats
  def total_monster_stats
    monsters.sum(:power) + monsters.sum(:speed) + monsters.sum(:defense) + monsters.sum(:health)
  end

  # Return the monsters that are not the active one =? stable
  def stable_monsters
    monsters.where.not(id: active_monster_id)
  end

  # Stable can have 2 monsters max
  def stable_full?
    stable_monsters.count >= 2
  end

  # Check if user doesn't have a monster on them
  def needs_monster?
    active_monster_id.nil?
  end

  private

  def set_default_timezone
    self.timezone ||= "UTC"
  end
end
