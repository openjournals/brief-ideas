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

ActiveRecord::Schema.define(version: 20141122024757) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "ideas", force: true do |t|
    t.string   "title"
    t.string   "sha"
    t.integer  "user_id"
    t.string   "state"
    t.text     "body"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "zenodo_id"
    t.string   "doi"
    t.string   "subject"
    t.string   "tags",       default: [], array: true
    t.integer  "vote_count", default: 0
  end

  add_index "ideas", ["tags"], name: "index_ideas_on_tags", using: :gin
  add_index "ideas", ["vote_count"], name: "index_ideas_on_vote_count", using: :btree

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
