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

ActiveRecord::Schema.define(version: 20141120174756) do

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
    t.text     "tags"
  end

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.string   "oauth_expires_at"
    t.string   "avatar_url"
    t.text     "extra"
    t.string   "email"
    t.string   "sha"
    t.boolean  "admin",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
