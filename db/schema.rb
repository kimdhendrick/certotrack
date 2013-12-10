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

ActiveRecord::Schema.define(version: 20131208230840) do

  create_table "certification_periods", force: true do |t|
    t.string   "trainer"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "units_achieved",   default: 0
    t.string   "comments"
    t.integer  "certification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "certification_types", force: true do |t|
    t.string   "name"
    t.string   "interval"
    t.integer  "units_required"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "certifications", force: true do |t|
    t.integer  "certification_type_id"
    t.integer  "employee_id"
    t.integer  "customer_id"
    t.boolean  "active",                         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "active_certification_period_id",                null: false
  end

  create_table "customers", force: true do |t|
    t.string   "name"
    t.string   "contact_person_name"
    t.string   "contact_phone_number"
    t.string   "contact_email"
    t.string   "account_number"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "active"
    t.boolean  "notification"
    t.boolean  "equipment_access"
    t.boolean  "certification_access"
    t.boolean  "vehicle_access"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "location_id"
    t.string   "employee_number"
    t.integer  "customer_id"
    t.boolean  "active",            default: true
    t.date     "deactivation_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equipment", force: true do |t|
    t.string   "serial_number"
    t.date     "last_inspection_date"
    t.string   "inspection_interval"
    t.string   "name"
    t.date     "expiration_date"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.integer  "location_id"
    t.integer  "employee_id"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_types", force: true do |t|
    t.string   "name"
    t.string   "expiration_type"
    t.string   "interval_date"
    t.integer  "interval_mileage"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "roles_mask"
    t.integer  "customer_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "vehicles", force: true do |t|
    t.string   "vehicle_number"
    t.string   "vin"
    t.string   "make"
    t.string   "vehicle_model"
    t.string   "license_plate"
    t.integer  "year"
    t.integer  "mileage"
    t.integer  "location_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
