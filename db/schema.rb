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

ActiveRecord::Schema.define(version: 20140505133323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "certification_periods", force: true do |t|
    t.text     "trainer"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "units_achieved",   default: 0
    t.text     "comments"
    t.integer  "certification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "certification_types", force: true do |t|
    t.text     "name"
    t.text     "interval"
    t.integer  "units_required"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "created_by"
  end

  create_table "certifications", force: true do |t|
    t.integer  "certification_type_id"
    t.integer  "employee_id"
    t.integer  "customer_id"
    t.boolean  "active",                         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "active_certification_period_id",                null: false
    t.text     "created_by"
  end

  create_table "customers", force: true do |t|
    t.text     "name"
    t.text     "contact_person_name"
    t.text     "contact_phone_number"
    t.text     "contact_email"
    t.text     "account_number"
    t.text     "address1"
    t.text     "address2"
    t.text     "city"
    t.text     "state"
    t.text     "zip"
    t.boolean  "active"
    t.boolean  "equipment_access"
    t.boolean  "certification_access"
    t.boolean  "vehicle_access"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.integer  "location_id"
    t.text     "employee_number"
    t.integer  "customer_id"
    t.boolean  "active",            default: true
    t.date     "deactivation_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "created_by"
  end

  create_table "equipment", force: true do |t|
    t.text     "serial_number"
    t.date     "last_inspection_date"
    t.text     "inspection_interval"
    t.text     "name"
    t.date     "expiration_date"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.integer  "location_id"
    t.integer  "employee_id"
    t.text     "created_by"
  end

  create_table "locations", force: true do |t|
    t.text     "name"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "created_by"
  end

  create_table "old_passwords", force: true do |t|
    t.text     "encrypted_password",       null: false
    t.text     "password_salt"
    t.text     "password_archivable_type", null: false
    t.integer  "password_archivable_id",   null: false
    t.datetime "created_at"
  end

  add_index "old_passwords", ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree

  create_table "service_periods", force: true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "start_mileage"
    t.integer  "end_mileage"
    t.text     "comments"
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_types", force: true do |t|
    t.text     "name"
    t.text     "expiration_type"
    t.text     "interval_date"
    t.integer  "interval_mileage"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "created_by"
  end

  create_table "services", force: true do |t|
    t.integer  "service_type_id"
    t.integer  "vehicle_id"
    t.integer  "customer_id"
    t.integer  "active_service_period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "created_by"
  end

  create_table "users", force: true do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.text     "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "username"
    t.text     "encrypted_password",               default: "",      null: false
    t.integer  "sign_in_count",                    default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text     "current_sign_in_ip"
    t.text     "last_sign_in_ip"
    t.integer  "roles_mask"
    t.integer  "customer_id"
    t.boolean  "admin",                            default: false
    t.text     "expiration_notification_interval", default: "Never"
    t.datetime "password_changed_at"
  end

  add_index "users", ["password_changed_at"], name: "index_users_on_password_changed_at", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "vehicles", force: true do |t|
    t.text     "vehicle_number"
    t.text     "vin"
    t.text     "make"
    t.text     "vehicle_model"
    t.text     "license_plate"
    t.integer  "year"
    t.integer  "mileage"
    t.integer  "location_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "created_by"
  end

end
