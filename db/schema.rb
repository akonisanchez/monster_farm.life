# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_24_004711) do
  create_table "achievements", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monster_achievements", force: :cascade do |t|
    t.integer "monster_id", null: false
    t.integer "achievement_id", null: false
    t.datetime "earned_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_monster_achievements_on_achievement_id"
    t.index ["monster_id", "achievement_id"], name: "index_monster_achievements_on_monster_id_and_achievement_id", unique: true
    t.index ["monster_id"], name: "index_monster_achievements_on_monster_id"
  end

  create_table "monsters", force: :cascade do |t|
    t.string "name"
    t.integer "power"
    t.integer "speed"
    t.integer "defense"
    t.integer "health"
    t.integer "tiredness"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "training_streak", default: 0
    t.boolean "feeling_good", default: false
    t.boolean "hot_streak", default: false
    t.integer "hot_streak_bonus", default: 0
    t.index ["user_id"], name: "index_monsters_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gold"
    t.string "timezone", default: "UTC", null: false
  end

  add_foreign_key "monster_achievements", "achievements"
  add_foreign_key "monster_achievements", "monsters"
  add_foreign_key "monsters", "users"
end
