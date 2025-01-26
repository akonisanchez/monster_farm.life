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

  belongs_to :active_monster, class_name: "Monster", optional: true

  # Set timezone from browser on signup
  before_validation :set_default_timezone

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
