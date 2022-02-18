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

ActiveRecord::Schema.define(version: 2022_02_18_185018) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_deck_party_card_parents", force: :cascade do |t|
    t.bigint "account_deck_id", null: false
    t.bigint "party_card_parent_id", null: false
    t.index ["account_deck_id", "party_card_parent_id"], name: "index_account_deck_cards_on_id"
  end

  create_table "account_decks", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.integer "card_count", default: 0
    t.bigint "archetype_id", null: false
    t.bigint "race_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["archetype_id"], name: "index_account_decks_on_archetype_id"
    t.index ["race_id"], name: "index_account_decks_on_race_id"
    t.index ["user_id"], name: "index_account_decks_on_user_id"
  end

  create_table "archetypes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "resource_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "games", force: :cascade do |t|
    t.boolean "turn", default: true
    t.boolean "ongoing", default: true
    t.bigint "winner_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "mulligan"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "gamestate_decks", force: :cascade do |t|
    t.integer "card_count"
    t.bigint "player_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_gamestate_decks_on_game_id"
    t.index ["player_id"], name: "index_gamestate_decks_on_player_id"
  end

  create_table "party_card_gamestates", force: :cascade do |t|
    t.integer "health_cap"
    t.integer "health_current"
    t.integer "cost_current"
    t.integer "attack_cap"
    t.integer "attack_current"
    t.string "location"
    t.string "status"
    t.bigint "archetype_id", null: false
    t.bigint "party_card_parent_id", null: false
    t.bigint "gamestate_deck_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position"
    t.index ["archetype_id"], name: "index_party_card_gamestates_on_archetype_id"
    t.index ["gamestate_deck_id"], name: "index_party_card_gamestates_on_gamestate_deck_id"
    t.index ["party_card_parent_id"], name: "index_party_card_gamestates_on_party_card_parent_id"
  end

  create_table "party_card_parents", force: :cascade do |t|
    t.string "name"
    t.integer "cost_default"
    t.integer "attack_default"
    t.integer "health_default"
    t.string "tribe"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "archetype_id"
    t.index ["archetype_id"], name: "index_party_card_parents_on_archetype_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "health_cap"
    t.integer "health_current"
    t.integer "cost_cap"
    t.integer "cost_current"
    t.integer "resource_cap"
    t.integer "resource_current"
    t.boolean "turn_order"
    t.bigint "race_id", null: false
    t.bigint "archetype_id", null: false
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "attack_current", default: 0
    t.string "status", default: "default"
    t.index ["archetype_id"], name: "index_players_on_archetype_id"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["race_id"], name: "index_players_on_race_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "health_modifier"
    t.integer "cost_modifier"
    t.integer "resource_modifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "account_decks", "archetypes"
  add_foreign_key "account_decks", "races"
  add_foreign_key "account_decks", "users"
  add_foreign_key "games", "users", column: "winner_id"
  add_foreign_key "gamestate_decks", "games"
  add_foreign_key "gamestate_decks", "players"
  add_foreign_key "party_card_gamestates", "archetypes"
  add_foreign_key "party_card_gamestates", "gamestate_decks"
  add_foreign_key "party_card_gamestates", "party_card_parents"
  add_foreign_key "party_card_parents", "archetypes"
  add_foreign_key "players", "archetypes"
  add_foreign_key "players", "games"
  add_foreign_key "players", "races"
  add_foreign_key "players", "users"
end
