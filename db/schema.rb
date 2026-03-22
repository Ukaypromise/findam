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

ActiveRecord::Schema[8.0].define(version: 2026_03_22_161435) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "commission_payments", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "tenant_id"
    t.bigint "landlord_id", null: false
    t.decimal "amount", precision: 12, scale: 2
    t.decimal "tenant_percentage", precision: 5, scale: 2
    t.decimal "landlord_percentage", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.string "paystack_reference"
    t.datetime "paid_at"
    t.string "payment_url"
    t.datetime "landlord_confirmed_at"
    t.datetime "tenant_confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landlord_id"], name: "index_commission_payments_on_landlord_id"
    t.index ["listing_id"], name: "index_commission_payments_on_listing_id"
    t.index ["paystack_reference"], name: "index_commission_payments_on_paystack_reference", unique: true
    t.index ["status"], name: "index_commission_payments_on_status"
    t.index ["tenant_id"], name: "index_commission_payments_on_tenant_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "landlord_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landlord_id"], name: "index_conversations_on_landlord_id"
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
    t.index ["tenant_id", "landlord_id", "listing_id"], name: "index_conversations_uniqueness", unique: true
    t.index ["tenant_id"], name: "index_conversations_on_tenant_id"
  end

  create_table "flagged_listings", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "reporter_id", null: false
    t.string "reason", null: false
    t.boolean "resolved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_flagged_listings_on_listing_id"
    t.index ["reporter_id"], name: "index_flagged_listings_on_reporter_id"
    t.index ["resolved"], name: "index_flagged_listings_on_resolved"
  end

  create_table "inspection_bookings", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "landlord_id", null: false
    t.bigint "listing_id", null: false
    t.bigint "inspection_slot_id", null: false
    t.string "status", default: "pending", null: false
    t.string "cancelled_by"
    t.string "cancellation_reason"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inspection_slot_id"], name: "index_inspection_bookings_on_inspection_slot_id"
    t.index ["landlord_id"], name: "index_inspection_bookings_on_landlord_id"
    t.index ["listing_id"], name: "index_inspection_bookings_on_listing_id"
    t.index ["status"], name: "index_inspection_bookings_on_status"
    t.index ["tenant_id"], name: "index_inspection_bookings_on_tenant_id"
  end

  create_table "inspection_slots", force: :cascade do |t|
    t.bigint "landlord_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.boolean "is_booked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landlord_id"], name: "index_inspection_slots_on_landlord_id"
    t.index ["listing_id", "is_booked"], name: "index_inspection_slots_on_listing_id_and_is_booked"
    t.index ["listing_id"], name: "index_inspection_slots_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "landlord_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "price", precision: 12, scale: 2, null: false
    t.string "address", null: false
    t.string "city", null: false
    t.string "property_type", null: false
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.boolean "is_available", default: true, null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "is_available", "status"], name: "index_listings_on_city_and_is_available_and_status"
    t.index ["city"], name: "index_listings_on_city"
    t.index ["is_available"], name: "index_listings_on_is_available"
    t.index ["landlord_id"], name: "index_listings_on_landlord_id"
    t.index ["property_type"], name: "index_listings_on_property_type"
    t.index ["status"], name: "index_listings_on_status"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "sender_type", null: false
    t.bigint "sender_id", null: false
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["read_at"], name: "index_messages_on_read_at"
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id", null: false
    t.string "full_name"
    t.string "location"
    t.text "short_bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.boolean "nin_verified", default: false, null: false
    t.datetime "nin_verified_at"
    t.boolean "certified", default: false, null: false
    t.datetime "certified_at"
    t.boolean "top_landlord", default: false, null: false
    t.datetime "top_landlord_recalculated_at"
    t.index ["type"], name: "index_profiles_on_type"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.boolean "onboarding_completed", default: false, null: false
    t.datetime "onboarding_completed_at"
    t.string "approval_status", default: "pending", null: false
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.text "rejection_reason"
    t.text "suspension_reason"
    t.index ["approval_status"], name: "index_users_on_approval_status"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["onboarding_completed"], name: "index_users_on_onboarding_completed"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["type"], name: "index_users_on_type"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "commission_payments", "listings"
  add_foreign_key "commission_payments", "users", column: "landlord_id"
  add_foreign_key "commission_payments", "users", column: "tenant_id"
  add_foreign_key "conversations", "listings"
  add_foreign_key "conversations", "users", column: "landlord_id"
  add_foreign_key "conversations", "users", column: "tenant_id"
  add_foreign_key "flagged_listings", "listings"
  add_foreign_key "flagged_listings", "users", column: "reporter_id"
  add_foreign_key "inspection_bookings", "inspection_slots"
  add_foreign_key "inspection_bookings", "listings"
  add_foreign_key "inspection_bookings", "users", column: "landlord_id"
  add_foreign_key "inspection_bookings", "users", column: "tenant_id"
  add_foreign_key "inspection_slots", "listings"
  add_foreign_key "inspection_slots", "users", column: "landlord_id"
  add_foreign_key "listings", "users", column: "landlord_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "profiles", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
