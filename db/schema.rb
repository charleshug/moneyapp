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

ActiveRecord::Schema[7.0].define(version: 2023_02_05_183134) do
  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.integer "balance", default: 0, null: false
    t.boolean "on_budget", default: true, null: false
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.boolean "hidden", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hidden"], name: "index_categories_on_hidden"
    t.index ["name"], name: "index_categories_on_name"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "lines", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.string "memo"
    t.integer "trx_id", null: false
    t.integer "category_id", null: false
    t.string "line_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_lines_on_category_id"
    t.index ["line_type"], name: "index_lines_on_line_type"
    t.index ["trx_id"], name: "index_lines_on_trx_id"
  end

  create_table "trxes", force: :cascade do |t|
    t.date "date", null: false
    t.integer "amount", default: 0, null: false
    t.string "memo"
    t.integer "account_id", null: false
    t.integer "category_id", null: false
    t.integer "vendor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_trxes_on_account_id"
    t.index ["category_id"], name: "index_trxes_on_category_id"
    t.index ["date"], name: "index_trxes_on_date"
    t.index ["vendor_id"], name: "index_trxes_on_vendor_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_vendors_on_name"
  end

  add_foreign_key "lines", "categories"
  add_foreign_key "lines", "trxes"
  add_foreign_key "trxes", "accounts"
  add_foreign_key "trxes", "categories"
  add_foreign_key "trxes", "vendors"
end
