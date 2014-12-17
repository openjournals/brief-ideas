# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141217155347) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "idea_references", force: true do |t|
    t.integer  "idea_id"
    t.integer  "referenced_id"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "idea_references", ["body"], name: "index_idea_references_on_body", using: :btree
  add_index "idea_references", ["idea_id"], name: "index_idea_references_on_idea_id", using: :btree
  add_index "idea_references", ["referenced_id"], name: "index_idea_references_on_referenced_id", using: :btree

  create_table "ideas", force: true do |t|
    t.string   "title"
    t.string   "sha"
    t.integer  "user_id"
    t.string   "state"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "zenodo_id"
    t.string   "doi"
    t.string   "subject"
    t.string   "tags",          default: [], array: true
    t.integer  "vote_count",    default: 0
    t.integer  "view_count"
    t.integer  "counter_cache", default: 0
  end

  add_index "ideas", ["counter_cache"], name: "index_ideas_on_counter_cache", using: :btree
  add_index "ideas", ["tags"], name: "index_ideas_on_tags", using: :gin
  add_index "ideas", ["view_count"], name: "index_ideas_on_view_count", using: :btree
  add_index "ideas", ["vote_count"], name: "index_ideas_on_vote_count", using: :btree

  create_table "impressions", force: true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.string   "oauth_expires_at"
    t.string   "avatar_url"
    t.string   "email"
    t.string   "sha"
    t.boolean  "admin",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "extra"
  end

  create_table "votes", force: true do |t|
    t.integer  "user_id"
    t.integer  "idea_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["idea_id"], name: "index_votes_on_idea_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
