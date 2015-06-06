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

ActiveRecord::Schema.define(version: 20150605013914) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "audit_logs", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "idea_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audit_logs", ["idea_id"], name: "index_audit_logs_on_idea_id", using: :btree
  add_index "audit_logs", ["user_id"], name: "index_audit_logs_on_user_id", using: :btree

  create_table "authors", force: true do |t|
    t.integer  "user_id"
    t.integer  "idea_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authors", ["idea_id"], name: "index_authors_on_idea_id", using: :btree
  add_index "authors", ["user_id"], name: "index_authors_on_user_id", using: :btree

  create_table "authorships", force: true do |t|
    t.integer  "user_id"
    t.integer  "idea_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  add_index "authorships", ["idea_id"], name: "index_authorships_on_idea_id", using: :btree
  add_index "authorships", ["state"], name: "index_authorships_on_state", using: :btree
  add_index "authorships", ["user_id"], name: "index_authorships_on_user_id", using: :btree

  create_table "collection_ideas", force: true do |t|
    t.integer  "idea_id"
    t.integer  "collection_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collection_ideas", ["collection_id"], name: "index_collection_ideas_on_collection_id", using: :btree
  add_index "collection_ideas", ["idea_id"], name: "index_collection_ideas_on_idea_id", using: :btree

  create_table "collections", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sha"
    t.text     "description"
  end

  add_index "collections", ["sha"], name: "index_collections_on_sha", using: :btree
  add_index "collections", ["user_id"], name: "index_collections_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.string   "title",            limit: 50, default: ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.string   "role",                        default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

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
    t.string   "tags",                    default: [],    array: true
    t.integer  "vote_count",              default: 0
    t.integer  "view_count",              default: 0
    t.float    "score",                   default: 0.0
    t.boolean  "deleted",                 default: false
    t.boolean  "muted",                   default: false
    t.boolean  "tweeted",                 default: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "ideas", ["deleted"], name: "index_ideas_on_deleted", using: :btree
  add_index "ideas", ["muted"], name: "index_ideas_on_muted", using: :btree
  add_index "ideas", ["score"], name: "index_ideas_on_score", using: :btree
  add_index "ideas", ["state"], name: "index_ideas_on_state", using: :btree
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

  create_table "starburst_announcement_views", force: true do |t|
    t.integer  "user_id"
    t.integer  "announcement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "starburst_announcement_views", ["user_id", "announcement_id"], name: "starburst_announcement_view_index", unique: true, using: :btree

  create_table "starburst_announcements", force: true do |t|
    t.text     "title"
    t.text     "body"
    t.datetime "start_delivering_at"
    t.datetime "stop_delivering_at"
    t.text     "limit_to_users"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "category"
  end

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
    t.integer  "seen_idea_ids",    default: [0],   array: true
  end

  add_index "users", ["seen_idea_ids"], name: "index_users_on_seen_idea_ids", using: :gin

  create_table "votes", force: true do |t|
    t.integer  "user_id"
    t.integer  "idea_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["idea_id"], name: "index_votes_on_idea_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
