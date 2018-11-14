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

ActiveRecord::Schema.define(version: 2018_11_14_195649) do

  create_table "illustrator_translations", force: :cascade do |t|
    t.integer "illustrator_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "bio"
    t.index ["illustrator_id"], name: "index_illustrator_translations_on_illustrator_id"
    t.index ["locale"], name: "index_illustrator_translations_on_locale"
    t.index ["name"], name: "index_illustrator_translations_on_name"
  end

  create_table "illustrators", force: :cascade do |t|
    t.date "date_birth"
    t.date "date_death"
    t.boolean "is_public", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_birth"], name: "index_illustrators_on_date_birth"
    t.index ["date_death"], name: "index_illustrators_on_date_death"
    t.index ["is_public"], name: "index_illustrators_on_is_public"
  end

  create_table "news", force: :cascade do |t|
    t.date "date_publish"
    t.boolean "is_public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_publish"], name: "index_news_on_date_publish"
    t.index ["is_public"], name: "index_news_on_is_public"
  end

  create_table "news_translations", force: :cascade do |t|
    t.integer "news_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "summary"
    t.text "text"
    t.index ["locale"], name: "index_news_translations_on_locale"
    t.index ["news_id"], name: "index_news_translations_on_news_id"
    t.index ["title"], name: "index_news_translations_on_title"
  end

  create_table "publication_language_translations", force: :cascade do |t|
    t.integer "publication_language_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language"
    t.index ["locale"], name: "index_publication_language_translations_on_locale"
    t.index ["publication_language_id"], name: "index_3b9f159e130bba83a1635d416364467009519f06"
  end

  create_table "publication_languages", force: :cascade do |t|
    t.boolean "is_active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_publication_languages_on_is_active"
  end

  create_table "research_translations", force: :cascade do |t|
    t.integer "research_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "summary"
    t.text "text"
    t.index ["locale"], name: "index_research_translations_on_locale"
    t.index ["research_id"], name: "index_research_translations_on_research_id"
    t.index ["title"], name: "index_research_translations_on_title"
  end

  create_table "researches", force: :cascade do |t|
    t.date "date_publish"
    t.boolean "is_public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_publish"], name: "index_researches_on_date_publish"
    t.index ["is_public"], name: "index_researches_on_is_public"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "name"
    t.boolean "is_active", default: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_active"], name: "index_users_on_is_active"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id"
    t.string "foreign_key_name", null: false
    t.integer "foreign_key_id"
    t.index ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key"
    t.index ["version_id"], name: "index_version_associations_on_version_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 1073741823
    t.datetime "created_at"
    t.text "object_changes", limit: 1073741823
    t.integer "transaction_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

end
