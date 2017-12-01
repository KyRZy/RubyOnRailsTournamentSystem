# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171201144643) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matches", force: :cascade do |t|
    t.integer  "participant_a_id"
    t.integer  "participant_b_id"
    t.integer  "participant_a_score", default: 0
    t.integer  "participant_b_score", default: 0
    t.integer  "stage"
    t.boolean  "finished",            default: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "participants", force: :cascade do |t|
    t.integer  "tournament_id"
    t.integer  "team_id"
    t.integer  "seed",          default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "wins",          default: 0
    t.integer  "losses",        default: 0
    t.index ["team_id"], name: "index_participants_on_team_id", using: :btree
    t.index ["tournament_id"], name: "index_participants_on_tournament_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "encrypted_password"
    t.integer  "leader_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "salt"
  end

  create_table "tournament_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tournaments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "tournament_type_id"
    t.datetime "start_date"
    t.boolean  "finished",           default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "max_participants"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "team_id"
    t.string   "username"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["team_id"], name: "index_users_on_team_id", using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "participants", "teams"
  add_foreign_key "participants", "tournaments"
  add_foreign_key "users", "teams"
end
