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

ActiveRecord::Schema.define(version: 2018_12_26_135131) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "highlight_translations", force: :cascade do |t|
    t.integer "highlight_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "summary"
    t.string "link"
    t.boolean "is_public", default: false
    t.date "date_publish"
    t.index ["date_publish"], name: "index_highlight_translations_on_date_publish"
    t.index ["highlight_id"], name: "index_highlight_translations_on_highlight_id"
    t.index ["is_public"], name: "index_highlight_translations_on_is_public"
    t.index ["locale"], name: "index_highlight_translations_on_locale"
    t.index ["title"], name: "index_highlight_translations_on_title"
  end

  create_table "highlights", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_image_uid"
  end

  create_table "illustration_issues", force: :cascade do |t|
    t.bigint "illustration_id"
    t.bigint "issue_id"
    t.integer "page_number_start"
    t.integer "page_number_end"
    t.boolean "is_public", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["illustration_id"], name: "index_illustration_issues_on_illustration_id"
    t.index ["is_public"], name: "index_illustration_issues_on_is_public"
    t.index ["issue_id"], name: "index_illustration_issues_on_issue_id"
  end

  create_table "illustration_publications", force: :cascade do |t|
    t.bigint "illustration_id"
    t.bigint "publication_id"
    t.integer "page_number_start"
    t.integer "page_number_end"
    t.boolean "is_public", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["illustration_id"], name: "index_illustration_publications_on_illustration_id"
    t.index ["is_public"], name: "index_illustration_publications_on_is_public"
    t.index ["publication_id"], name: "index_illustration_publications_on_publication_id"
  end

  create_table "illustration_tags", force: :cascade do |t|
    t.bigint "illustration_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["illustration_id"], name: "index_illustration_tags_on_illustration_id"
    t.index ["tag_id"], name: "index_illustration_tags_on_tag_id"
  end

  create_table "illustration_translations", force: :cascade do |t|
    t.integer "illustration_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "context"
    t.boolean "is_public", default: false
    t.date "date_publish"
    t.index ["date_publish"], name: "index_illustration_translations_on_date_publish"
    t.index ["illustration_id"], name: "index_illustration_translations_on_illustration_id"
    t.index ["is_public"], name: "index_illustration_translations_on_is_public"
    t.index ["locale"], name: "index_illustration_translations_on_locale"
    t.index ["title"], name: "index_illustration_translations_on_title"
  end

  create_table "illustrations", force: :cascade do |t|
    t.bigint "illustrator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_uid"
    t.index ["illustrator_id"], name: "index_illustrations_on_illustrator_id"
  end

  create_table "illustrator_translations", force: :cascade do |t|
    t.integer "illustrator_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "bio"
    t.boolean "is_public", default: false
    t.date "date_publish"
    t.index ["date_publish"], name: "index_illustrator_translations_on_date_publish"
    t.index ["illustrator_id"], name: "index_illustrator_translations_on_illustrator_id"
    t.index ["is_public"], name: "index_illustrator_translations_on_is_public"
    t.index ["locale"], name: "index_illustrator_translations_on_locale"
    t.index ["name"], name: "index_illustrator_translations_on_name"
  end

  create_table "illustrators", force: :cascade do |t|
    t.date "date_birth"
    t.date "date_death"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_uid"
    t.index ["date_birth"], name: "index_illustrators_on_date_birth"
    t.index ["date_death"], name: "index_illustrators_on_date_death"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "publication_id"
    t.string "issue_number"
    t.date "date_publication"
    t.boolean "is_public", default: false
    t.date "date_publish"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_image_uid"
    t.string "scanned_file_uid"
    t.index ["date_publication"], name: "index_issues_on_date_publication"
    t.index ["date_publish"], name: "index_issues_on_date_publish"
    t.index ["is_public"], name: "index_issues_on_is_public"
    t.index ["publication_id"], name: "index_issues_on_publication_id"
  end

  create_table "lit_incomming_localizations", id: :serial, force: :cascade do |t|
    t.text "translated_value"
    t.integer "locale_id"
    t.integer "localization_key_id"
    t.integer "localization_id"
    t.string "locale_str"
    t.string "localization_key_str"
    t.integer "source_id"
    t.integer "incomming_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["incomming_id"], name: "index_lit_incomming_localizations_on_incomming_id"
    t.index ["locale_id"], name: "index_lit_incomming_localizations_on_locale_id"
    t.index ["localization_id"], name: "index_lit_incomming_localizations_on_localization_id"
    t.index ["localization_key_id"], name: "index_lit_incomming_localizations_on_localization_key_id"
    t.index ["source_id"], name: "index_lit_incomming_localizations_on_source_id"
  end

  create_table "lit_locales", id: :serial, force: :cascade do |t|
    t.string "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_hidden", default: false
  end

  create_table "lit_localization_keys", id: :serial, force: :cascade do |t|
    t.string "localization_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_completed", default: false
    t.boolean "is_starred", default: false
    t.index ["localization_key"], name: "index_lit_localization_keys_on_localization_key", unique: true
  end

  create_table "lit_localization_versions", id: :serial, force: :cascade do |t|
    t.text "translated_value"
    t.integer "localization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["localization_id"], name: "index_lit_localization_versions_on_localization_id"
  end

  create_table "lit_localizations", id: :serial, force: :cascade do |t|
    t.integer "locale_id"
    t.integer "localization_key_id"
    t.text "default_value"
    t.text "translated_value"
    t.boolean "is_changed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["locale_id"], name: "index_lit_localizations_on_locale_id"
    t.index ["localization_key_id"], name: "index_lit_localizations_on_localization_key_id"
  end

  create_table "lit_sources", id: :serial, force: :cascade do |t|
    t.string "identifier"
    t.string "url"
    t.string "api_key"
    t.datetime "last_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "sync_complete"
  end

  create_table "news", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_image_uid"
  end

  create_table "news_translations", force: :cascade do |t|
    t.integer "news_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "summary"
    t.text "text"
    t.boolean "is_public", default: false
    t.date "date_publish"
    t.index ["date_publish"], name: "index_news_translations_on_date_publish"
    t.index ["is_public"], name: "index_news_translations_on_is_public"
    t.index ["locale"], name: "index_news_translations_on_locale"
    t.index ["news_id"], name: "index_news_translations_on_news_id"
    t.index ["title"], name: "index_news_translations_on_title"
  end

  create_table "publication_editor_translations", force: :cascade do |t|
    t.integer "publication_editor_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "editor"
    t.string "publisher"
    t.index ["locale"], name: "index_publication_editor_translations_on_locale"
    t.index ["publication_editor_id"], name: "index_publication_editor_translations_on_publication_editor_id"
  end

  create_table "publication_editors", force: :cascade do |t|
    t.bigint "publication_id"
    t.integer "year_start"
    t.integer "year_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "index_publication_editors_on_publication_id"
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

  create_table "publication_translations", force: :cascade do |t|
    t.integer "publication_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "about"
    t.string "editor"
    t.string "publisher"
    t.string "writer"
    t.boolean "is_public", default: false
    t.date "date_publish"
    t.index ["date_publish"], name: "index_publication_translations_on_date_publish"
    t.index ["is_public"], name: "index_publication_translations_on_is_public"
    t.index ["locale"], name: "index_publication_translations_on_locale"
    t.index ["publication_id"], name: "index_publication_translations_on_publication_id"
    t.index ["title"], name: "index_publication_translations_on_title"
  end

  create_table "publications", force: :cascade do |t|
    t.integer "publication_type", default: 0
    t.bigint "publication_language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.string "cover_image_uid"
    t.string "scanned_file_uid"
    t.index ["publication_language_id"], name: "index_publications_on_publication_language_id"
    t.index ["publication_type"], name: "index_publications_on_publication_type"
    t.index ["year"], name: "index_publications_on_year"
  end

  create_table "research_translations", force: :cascade do |t|
    t.integer "research_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "summary"
    t.text "text"
    t.boolean "is_public", default: false
    t.date "date_publish"
    t.index ["date_publish"], name: "index_research_translations_on_date_publish"
    t.index ["is_public"], name: "index_research_translations_on_is_public"
    t.index ["locale"], name: "index_research_translations_on_locale"
    t.index ["research_id"], name: "index_research_translations_on_research_id"
    t.index ["title"], name: "index_research_translations_on_title"
  end

  create_table "researches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_image_uid"
  end

  create_table "tag_translations", force: :cascade do |t|
    t.integer "tag_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["locale"], name: "index_tag_translations_on_locale"
    t.index ["name"], name: "index_tag_translations_on_name"
    t.index ["tag_id"], name: "index_tag_translations_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "thumbs", force: :cascade do |t|
    t.string "uid"
    t.string "job"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job"], name: "index_thumbs_on_job"
    t.index ["uid"], name: "index_thumbs_on_uid"
  end

  create_table "translations", force: :cascade do |t|
    t.string "locale"
    t.string "key"
    t.text "value"
    t.text "interpolations"
    t.boolean "is_proc", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale", "key"], name: "index_translations_on_locale_and_key"
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
    t.datetime "deleted_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
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
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "transaction_id"
    t.string "locale"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["transaction_id"], name: "index_versions_on_transaction_id"
  end

end
