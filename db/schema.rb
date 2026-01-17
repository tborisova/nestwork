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

ActiveRecord::Schema[8.0].define(version: 2026_01_17_200001) do
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

  create_table "comments", force: :cascade do |t|
    t.text "comment"
    t.boolean "resolved", default: false, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commentable_type"
    t.integer "commentable_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "firms", force: :cascade do |t|
    t.string "name", null: false
    t.string "website_url"
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "firms_clients", force: :cascade do |t|
    t.integer "firm_id", null: false
    t.integer "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_firms_clients_on_client_id"
    t.index ["firm_id", "client_id"], name: "index_firms_clients_unique", unique: true
    t.index ["firm_id"], name: "index_firms_clients_on_firm_id"
  end

  create_table "firms_designers", force: :cascade do |t|
    t.integer "firm_id", null: false
    t.integer "designer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["designer_id"], name: "index_firms_designers_on_designer_id"
    t.index ["firm_id", "designer_id"], name: "index_firms_designers_unique", unique: true
    t.index ["firm_id"], name: "index_firms_designers_on_firm_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name"
    t.string "link"
    t.integer "price"
    t.integer "quantity"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_products_on_room_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.integer "firm_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["firm_id"], name: "index_projects_on_firm_id"
  end

  create_table "projects_clients", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_projects_clients_on_client_id"
    t.index ["project_id", "client_id"], name: "index_projects_clients_unique", unique: true
    t.index ["project_id"], name: "index_projects_clients_on_project_id"
  end

  create_table "projects_designers", force: :cascade do |t|
    t.integer "designer_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["designer_id"], name: "index_projects_designers_on_designer_id"
    t.index ["project_id", "designer_id"], name: "index_projects_designers_unique", unique: true
    t.index ["project_id"], name: "index_projects_designers_on_project_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.integer "project_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_rooms_on_project_id"
  end

  create_table "selection_options", force: :cascade do |t|
    t.integer "selection_id", null: false
    t.string "name"
    t.string "link"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["selection_id"], name: "index_selection_options_on_selection_id"
  end

  create_table "selections", force: :cascade do |t|
    t.integer "room_id", null: false
    t.string "name"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_selections_on_room_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "users"
  add_foreign_key "firms", "users", column: "owner_id"
  add_foreign_key "firms_clients", "firms"
  add_foreign_key "firms_clients", "users", column: "client_id"
  add_foreign_key "firms_designers", "firms"
  add_foreign_key "firms_designers", "users", column: "designer_id"
  add_foreign_key "products", "rooms"
  add_foreign_key "projects", "firms"
  add_foreign_key "projects_clients", "projects"
  add_foreign_key "projects_clients", "users", column: "client_id"
  add_foreign_key "projects_designers", "projects"
  add_foreign_key "projects_designers", "users", column: "designer_id"
  add_foreign_key "rooms", "projects"
  add_foreign_key "selection_options", "selections"
  add_foreign_key "selections", "rooms"
end
