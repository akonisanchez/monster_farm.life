class User < ApplicationRecord
    has_secure_password

    validates :username, presence: true, uniqueness: true,
      length: { minimum: 3, maximum: 20 }
    validates :password, length: { minimum: 6 }, on: :create

    has_one :monster, dependent: :destroy
end
