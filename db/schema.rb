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

ActiveRecord::Schema[7.0].define(version: 2025_06_19_141151) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "families", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_families_on_name"
  end

  create_table "milestones", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.date "milestone_date", null: false
    t.string "milestone_type", null: false
    t.string "milestoneable_type", null: false
    t.bigint "milestoneable_id", null: false
    t.bigint "created_by_user_id", null: false
    t.boolean "is_private", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["milestone_date"], name: "index_milestones_on_milestone_date"
    t.index ["milestone_type"], name: "index_milestones_on_milestone_type"
    t.index ["milestoneable_type", "milestoneable_id"], name: "index_milestones_on_milestoneable"
    t.index ["milestoneable_type", "milestoneable_id"], name: "index_milestones_on_milestoneable_type_and_milestoneable_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "private", default: false, null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "posts_users", id: false, force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.index ["post_id", "user_id"], name: "index_posts_users_on_post_id_and_user_id"
    t.index ["user_id", "post_id"], name: "index_posts_users_on_user_id_and_post_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "related_user_id", null: false
    t.string "relationship_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["related_user_id"], name: "index_relationships_on_related_user_id"
    t.index ["relationship_type"], name: "index_relationships_on_relationship_type"
    t.index ["user_id", "related_user_id"], name: "index_relationships_on_user_id_and_related_user_id", unique: true
    t.index ["user_id"], name: "index_relationships_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "nickname"
    t.date "birthdate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "password_digest"
    t.boolean "claimed", default: false
    t.integer "role", default: 0
    t.bigint "family_id"
    t.index ["family_id"], name: "index_users_on_family_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "milestones", "users", column: "created_by_user_id"
  add_foreign_key "posts", "users"
  add_foreign_key "relationships", "users"
  add_foreign_key "relationships", "users", column: "related_user_id"
  add_foreign_key "users", "families"
end
