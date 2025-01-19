class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true,
            uniqueness: { message: "is already taken" },
            length: { minimum: 3, maximum: 20,
                     message: "must be between 3 and 20 characters" }
  validates :password, length: { minimum: 6,
                     message: "must be at least 6 characters long" },
            on: :create

  has_one :monster, dependent: :destroy
end