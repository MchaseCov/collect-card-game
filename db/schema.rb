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

ActiveRecord::Schema.define(version: 2022_05_10_170314) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abilities", force: :cascade do |t|
    t.string "action"
    t.integer "modifier"
    t.string "body_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "random", default: 0
  end

  create_table "abilities_buffs", id: false, force: :cascade do |t|
    t.bigint "ability_id"
    t.bigint "buff_id"
    t.index ["ability_id"], name: "index_abilities_buffs_on_ability_id"
    t.index ["buff_id"], name: "index_abilities_buffs_on_buff_id"
  end

  create_table "ability_triggers", force: :cascade do |t|
    t.bigint "ability_id", null: false
    t.integer "trigger", default: 0
    t.integer "target_scope", default: 0
    t.integer "alignment", default: 0
    t.integer "target_type", default: 0
    t.integer "additional_scoping"
    t.bigint "card_constant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ability_id"], name: "index_ability_triggers_on_ability_id"
    t.index ["card_constant_id"], name: "index_ability_triggers_on_card_constant_id"
    t.index ["trigger"], name: "index_ability_triggers_on_trigger"
  end

  create_table "account_deck_card_references", force: :cascade do |t|
    t.bigint "account_deck_id", null: false
    t.bigint "card_reference_id", null: false
    t.index ["account_deck_id", "card_reference_id"], name: "index_account_deck_card_references_id"
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

  create_table "active_buffs", force: :cascade do |t|
    t.bigint "buff_id", null: false
    t.string "buffable_type"
    t.bigint "buffable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buff_id"], name: "index_active_buffs_on_buff_id"
    t.index ["buffable_type", "buffable_id"], name: "index_active_buffs_on_buffable"
  end

  create_table "active_listener_cards", force: :cascade do |t|
    t.bigint "active_listener_id", null: false
    t.bigint "card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["active_listener_id"], name: "index_active_listener_cards_on_active_listener_id"
    t.index ["card_id"], name: "index_active_listener_cards_on_card_id"
  end

  create_table "active_listeners", force: :cascade do |t|
    t.bigint "keyword_id"
    t.bigint "card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_active_listeners_on_card_id"
    t.index ["keyword_id"], name: "index_active_listeners_on_keyword_id"
  end

  create_table "ai_decision_data", force: :cascade do |t|
    t.string "type"
    t.json "card_weight"
    t.bigint "card_constant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_constant_id"], name: "index_ai_decision_data_on_card_constant_id"
  end

  create_table "archetypes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "resource_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "color", default: 0
  end

  create_table "buffs", force: :cascade do |t|
    t.string "name"
    t.string "target_method"
    t.string "removal_method"
    t.integer "modifier"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "buffs_keywords", id: false, force: :cascade do |t|
    t.bigint "buff_id"
    t.bigint "keyword_id"
    t.index ["buff_id"], name: "index_buffs_keywords_on_buff_id"
    t.index ["keyword_id"], name: "index_buffs_keywords_on_keyword_id"
  end

  create_table "card_constants", force: :cascade do |t|
    t.string "tribe"
    t.bigint "archetype_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "summoner_id"
    t.index ["archetype_id"], name: "index_card_constants_on_archetype_id"
    t.index ["summoner_id"], name: "index_card_constants_on_summoner_id"
  end

  create_table "card_references", force: :cascade do |t|
    t.integer "cost"
    t.integer "attack"
    t.integer "health"
    t.string "card_type"
    t.bigint "card_constant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_constant_id"], name: "index_card_references_on_card_constant_id"
  end

  create_table "cards", force: :cascade do |t|
    t.integer "cost"
    t.integer "health"
    t.integer "attack"
    t.integer "health_cap"
    t.integer "position"
    t.string "type"
    t.bigint "gamestate_deck_id", null: false
    t.bigint "card_constant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "silenced", default: false
    t.integer "status", default: 0
    t.integer "location", default: 0
    t.boolean "taunting", default: false
    t.index ["card_constant_id"], name: "index_cards_on_card_constant_id"
    t.index ["gamestate_deck_id"], name: "index_cards_on_gamestate_deck_id"
    t.index ["location"], name: "index_cards_on_location"
    t.index ["status"], name: "index_cards_on_status"
    t.index ["type"], name: "index_cards_on_type"
  end

  create_table "games", force: :cascade do |t|
    t.boolean "turn", default: true
    t.boolean "ongoing", default: true
    t.datetime "turn_time", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type", default: "MultiplayerGame"
    t.integer "status", default: 0
    t.index ["status"], name: "index_games_on_status"
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

  create_table "keywords", force: :cascade do |t|
    t.string "type"
    t.boolean "player_choice", default: false
    t.string "target", default: [], array: true
    t.string "action"
    t.integer "modifier"
    t.text "body_text"
    t.bigint "card_constant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "listening_condition"
    t.index ["card_constant_id"], name: "index_keywords_on_card_constant_id"
    t.index ["type", "card_constant_id"], name: "index_keywords_on_type_and_card_constant_id", unique: true
    t.index ["type"], name: "index_keywords_on_type"
  end

  create_table "players", force: :cascade do |t|
    t.integer "health_cap"
    t.integer "health_current"
    t.integer "cost_cap"
    t.integer "cost_current"
    t.integer "resource_cap"
    t.integer "resource_current"
    t.boolean "turn_order"
    t.integer "attack", default: 0
    t.bigint "race_id", null: false
    t.bigint "archetype_id", null: false
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
    t.index ["archetype_id"], name: "index_players_on_archetype_id"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["race_id"], name: "index_players_on_race_id"
    t.index ["status"], name: "index_players_on_status"
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

  add_foreign_key "ability_triggers", "abilities"
  add_foreign_key "ability_triggers", "card_constants"
  add_foreign_key "account_decks", "archetypes"
  add_foreign_key "account_decks", "races"
  add_foreign_key "account_decks", "users"
  add_foreign_key "active_buffs", "buffs"
  add_foreign_key "active_listener_cards", "active_listeners"
  add_foreign_key "active_listener_cards", "cards"
  add_foreign_key "active_listeners", "cards"
  add_foreign_key "active_listeners", "keywords"
  add_foreign_key "ai_decision_data", "card_constants"
  add_foreign_key "card_constants", "archetypes"
  add_foreign_key "card_constants", "card_constants", column: "summoner_id"
  add_foreign_key "card_references", "card_constants"
  add_foreign_key "cards", "card_constants"
  add_foreign_key "cards", "gamestate_decks"
  add_foreign_key "gamestate_decks", "games"
  add_foreign_key "gamestate_decks", "players"
  add_foreign_key "keywords", "card_constants"
  add_foreign_key "players", "archetypes"
  add_foreign_key "players", "games"
  add_foreign_key "players", "races"
  add_foreign_key "players", "users"
end
