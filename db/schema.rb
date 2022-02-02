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

ActiveRecord::Schema.define(version: 2022_02_02_185155) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_decks", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.integer "card_count"
    t.bigint "archetype_id", null: false
    t.bigint "race_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["archetype_id"], name: "index_account_decks_on_archetype_id"
    t.index ["race_id"], name: "index_account_decks_on_race_id"
    t.index ["user_id"], name: "index_account_decks_on_user_id"
  end

  create_table "account_decks_party_card_parents", id: false, force: :cascade do |t|
    t.bigint "account_deck_id", null: false
    t.bigint "party_card_parent_id", null: false
    t.index ["account_deck_id", "party_card_parent_id"], name: "index_account_deck_cards_on_id"
  end

  create_table "archetypes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "resource_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "party_card_parents", force: :cascade do |t|
    t.string "name"
    t.integer "cost_default"
    t.integer "attack_default"
    t.integer "health_default"
    t.string "tribe"
    t.string "archetype"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
end
