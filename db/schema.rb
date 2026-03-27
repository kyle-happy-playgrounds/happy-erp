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

ActiveRecord::Schema[7.1].define(version: 2026_03_13_203634) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "happy_activtiy_categories", force: :cascade do |t|
    t.bigserial "happy_task_category_id", null: false
    t.string "category_name"
    t.index ["id"], name: "index_happy_activtiy_categories_on_id", unique: true
  end

  create_table "happy_categories", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_vendor_id"
    t.string "category"
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["happy_vendor_id", "category"], name: "index_happy_category", unique: true
  end

  create_table "happy_companies", force: :cascade do |t|
    t.string "company_name"
    t.string "company_type"
    t.string "region"
    t.string "business_phone"
    t.string "fax"
    t.string "website"
    t.string "company_geocode"
    t.float "company_lat"
    t.float "company_long"
    t.string "company_street1"
    t.string "company_street2"
    t.string "company_city"
    t.string "company_state"
    t.string "company_country"
    t.string "company_zipcode"
    t.string "company_county"
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
  end

  create_table "happy_customer_companies", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.string "company_name"
    t.string "customer_type"
    t.boolean "taxable", default: true
    t.string "region"
    t.string "business_phone"
    t.string "cell_phone"
    t.string "fax"
    t.string "customer_geocode"
    t.float "customer_lat"
    t.float "customer_long"
    t.string "customer_street1"
    t.string "customer_street2"
    t.string "customer_city"
    t.string "customer_state"
    t.string "customer_country"
    t.string "customer_zipcode"
    t.string "customer_county"
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.string "company_name_normalized"
    t.index ["company_name"], name: "index_happy_customer_companies_on_company_name"
    t.index ["happy_company_id", "company_name_normalized"], name: "uniq_hcc_norm_name_per_tenant", unique: true, where: "((company_name_normalized IS NOT NULL) AND ((company_name_normalized)::text <> ''::text))"
  end

  create_table "happy_customers", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_customer_company_id"
    t.string "customer_name"
    t.string "customer_type"
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "title"
    t.string "suffix"
    t.string "email"
    t.string "website"
    t.boolean "taxable", default: true
    t.string "terms"
    t.string "region"
    t.string "home_phone"
    t.string "business_phone"
    t.string "fax"
    t.string "mailing_geocode"
    t.float "mailing_lat"
    t.float "mailing_long"
    t.string "mailing_street1"
    t.string "mailing_street2"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_country"
    t.string "mailing_zipcode"
    t.string "mailing_county"
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index "happy_company_id, lower(TRIM(BOTH FROM email))", name: "idx_happy_customers_email_per_tenant", where: "((email IS NOT NULL) AND (TRIM(BOTH FROM email) <> ''::text))"
    t.index "happy_company_id, lower(TRIM(BOTH FROM email))", name: "uniq_happy_customers_email_per_tenant", unique: true, where: "((email IS NOT NULL) AND (TRIM(BOTH FROM email) <> ''::text))"
    t.index ["happy_customer_company_id"], name: "idx_happy_customers_company_id"
    t.index ["id"], name: "index_happy_customers_on_id", unique: true
    t.index ["id"], name: "primary_customer_index", unique: true
    t.index ["last_name"], name: "index_happy_customers_on_last_name"
  end

  create_table "happy_install_sites", force: :cascade do |t|
    t.bigint "happy_customer_id"
    t.string "site_name"
    t.string "description"
    t.string "street1"
    t.string "street2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.string "site_type"
    t.float "latitude"
    t.float "longitude"
    t.string "category"
    t.string "region"
    t.string "size_description"
    t.decimal "length", precision: 10, scale: 3, default: "0.0"
    t.decimal "width", precision: 10, scale: 3, default: "0.0"
    t.decimal "height", precision: 10, scale: 3, default: "0.0"
    t.string "image_name"
    t.string "image_url"
    t.boolean "isFeatured", default: false
    t.boolean "isFavorite", default: false
    t.string "status"
    t.string "user_id"
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["id"], name: "index_happy_install_sites_on_id", unique: true
    t.index ["site_name"], name: "by_site_name", unique: true
  end

  create_table "happy_po_lines", force: :cascade do |t|
    t.bigint "happy_po_id"
    t.string "number"
    t.integer "position", default: 0, null: false
    t.string "product_id"
    t.string "vendor_product_id"
    t.string "customer_product_id"
    t.text "description"
    t.string "color"
    t.string "unit_of_measure"
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.decimal "quantity_received", precision: 10, scale: 2, null: false
    t.date "ship_date"
    t.date "last_received_date"
    t.boolean "taxable", default: true
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "shipping_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "list_price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "discount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "msrp_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_line_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "adjustments", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "happy_vendor_id"
    t.string "vendor_name"
    t.decimal "buyout_unit_price", precision: 10, scale: 2, null: false
    t.decimal "margin", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_cost_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.text "internal_notes"
    t.text "external_notes"
    t.decimal "weight", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "purchase_discount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "sell_discount", precision: 10, scale: 2, default: "0.0", null: false
    t.binary "po_line_image"
    t.string "po_line_image_url"
    t.string "status"
    t.bigint "user_id"
    t.bigint "user_id_add"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_po_id"], name: "index_happy_po_lines_on_happy_po_id"
    t.index ["id", "position"], name: "index_happy_po_lines_on_id_position"
    t.index ["id"], name: "index_happy_po_lines_on_id", unique: true
  end

  create_table "happy_po_receiver_logs", force: :cascade do |t|
    t.bigint "happy_po_line_id"
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_vendor_id", null: false
    t.string "number", null: false
    t.integer "sub", null: false
    t.integer "count", default: 0, null: false
    t.string "record_type"
    t.date "ship_date"
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.decimal "quantity_received", precision: 10, scale: 2, null: false
    t.string "status"
    t.bigint "user_id"
    t.bigint "user_id_add"
    t.bigint "user_id_update"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_po_line_id"], name: "index_happy_po_receiver_logs_on_happy_po_lines_id"
    t.index ["happy_vendor_id", "number", "sub"], name: "index_happy_po_receiver_log_on_quote_vendor_id"
    t.index ["happy_vendor_id"], name: "index_happy_po_receiver_logs_on_happy_vendor_id"
  end

  create_table "happy_po_receivers", force: :cascade do |t|
    t.bigint "happy_po_line_id"
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_vendor_id", null: false
    t.string "number", null: false
    t.integer "sub", null: false
    t.integer "count", default: 0, null: false
    t.string "record_type"
    t.date "ship_date"
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.decimal "quantity_received", precision: 10, scale: 2, default: "0.0", null: false
    t.string "status"
    t.bigint "user_id"
    t.bigint "user_id_add"
    t.bigint "user_id_update"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_po_line_id"], name: "index_happy_po_receivers_on_happy_po_lines_id"
    t.index ["happy_vendor_id", "number", "sub"], name: "index_happy_po_receivers_on_quote_vendor_id", unique: true
    t.index ["happy_vendor_id"], name: "index_happy_po_receivers_on_happy_vendor_id"
  end

  create_table "happy_pos", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_customer_id"
    t.bigint "happy_vendor_id"
    t.bigint "happy_quote_id"
    t.string "number"
    t.integer "sub", default: 0, null: false
    t.string "record_type"
    t.date "quote_date"
    t.date "order_date"
    t.string "shipping_method"
    t.string "fob"
    t.string "terms"
    t.date "requested_ship_date"
    t.date "actual_ship_date"
    t.date "estimated_delivery_date"
    t.date "actual_delivery_date"
    t.date "last_received_date"
    t.date "deliver_not_before_date"
    t.date "deliver_not_after_date"
    t.string "shipping_geocode"
    t.float "shipping_lat"
    t.float "shipping_long"
    t.string "shipping_street1"
    t.string "shipping_street2"
    t.string "shipping_city"
    t.string "shipping_state"
    t.string "shipping_zipcode"
    t.string "shipping_county"
    t.boolean "shipaddress_same_billaddress"
    t.decimal "shipping_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "item_total", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "order_subtotal", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "adjustment_total", precision: 10, scale: 2, default: "0.0", null: false
    t.string "state"
    t.string "user_name"
    t.string "end_user_name"
    t.string "end_user_phone"
    t.string "end_user_email"
    t.decimal "payment_total", precision: 10, scale: 2, default: "0.0"
    t.string "shipment_state"
    t.string "payment_state"
    t.string "email"
    t.text "special_instructions"
    t.text "internal_notes"
    t.text "external_notes"
    t.string "currency"
    t.decimal "shipment_total", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "tax_rate", precision: 10, scale: 3, default: "0.0"
    t.decimal "additional_tax_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "included_tax_total", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "item_count", default: 0
    t.binary "po_image"
    t.string "po_image_url"
    t.datetime "approved_at", precision: nil
    t.string "approver_name"
    t.boolean "confirmation_delivered", default: false
    t.boolean "discount_override", default: false
    t.boolean "tax_override", default: false
    t.string "mailing_street1"
    t.string "mailing_street2"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_zipcode"
    t.boolean "copy", default: false
    t.datetime "canceled_at", precision: nil
    t.integer "canceler_id"
    t.string "status"
    t.bigint "user_id"
    t.bigint "user_id_add"
    t.bigint "user_id_update"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_vendor_id", "number", "sub"], name: "index_happy_pos_on_quote_vendor_id", unique: true
    t.index ["happy_vendor_id"], name: "index_happy_pos_on_happy_vendor_id"
    t.index ["id"], name: "index_happy_pos_on_id", unique: true
    t.index ["number"], name: "index_happy_pos_on_number"
  end

  create_table "happy_process_flows", force: :cascade do |t|
    t.bigint "happy_standard_task_id"
    t.bigint "happy_standard_process_id"
    t.integer "position"
    t.string "process_name"
    t.string "task_name"
    t.string "flow_name"
    t.string "dependency", default: [], array: true
    t.string "status"
    t.boolean "open"
    t.bigint "user_id"
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["id"], name: "index_happy_process_flows_on_id", unique: true
  end

  create_table "happy_products", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_category_id"
    t.bigint "happy_vendor_id"
    t.bigint "happy_vendor_pricelist_id"
    t.string "part_number"
    t.string "description"
    t.string "pricelist_name"
    t.decimal "list_price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "weight", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "ipema_certified", default: true
    t.boolean "cpsc_certified", default: true
    t.boolean "csa_certified", default: true
    t.boolean "en_certified", default: true
    t.boolean "astm_certified", default: true
    t.decimal "purchase_discount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "dealer_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "weighted_average_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_category_id"], name: "index_happy_products_on_happy_category_id"
    t.index ["happy_vendor_id", "part_number"], name: "index_happy_products_on_happy_vendor_id_and_part_number", unique: true
    t.index ["id"], name: "index_happy_products_on_id", unique: true
    t.index ["part_number"], name: "index_happy_products_on_products"
  end

  create_table "happy_profit_centers", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.string "profit_center_name"
    t.string "sales_region"
    t.string "business_phone"
    t.string "cell_phone"
    t.string "email"
    t.string "fax"
    t.string "profit_center_manager"
    t.string "profit_center_geocode"
    t.float "profit_center_lat"
    t.float "profit_center_long"
    t.string "profit_center_street1"
    t.string "profit_center_street2"
    t.string "profit_center_city"
    t.string "profit_center_state"
    t.string "profit_center_country"
    t.string "profit_center_zipcode"
    t.string "profit_center_county"
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_company_id"], name: "index_happy_profit_centers_on_happy_company_id", unique: true
  end

  create_table "happy_project_managers", force: :cascade do |t|
    t.bigint "happy_project_id"
    t.string "role"
    t.boolean "is_project_manager"
    t.string "status"
    t.bigint "user_id", null: false
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["happy_project_id"], name: "index_happy_project_managers_on_happy_project_id"
    t.index ["id"], name: "index_happy_project_managers_on_id", unique: true
  end

  create_table "happy_project_members", force: :cascade do |t|
    t.bigint "happy_customer_id"
    t.bigint "happy_vendor_id"
    t.string "first_name"
    t.string "last_name"
    t.string "title"
    t.string "role"
    t.string "state"
    t.string "email"
    t.string "phone_number"
    t.boolean "is_sms"
    t.boolean "is_muted"
    t.string "status"
    t.bigint "user_id", null: false
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["id"], name: "index_happy_project_members_on_id", unique: true
  end

  create_table "happy_project_tasks", force: :cascade do |t|
    t.bigint "happy_project_id"
    t.bigint "happy_vendor_id"
    t.bigint "happy_task_activity_id"
    t.bigint "happy_standard_task_id"
    t.bigint "happy_standard_process_id"
    t.integer "position"
    t.string "number"
    t.integer "sub"
    t.string "task_name"
    t.string "description"
    t.string "sales_order"
    t.string "priority"
    t.string "dependency", default: [], array: true
    t.bigint "lead_time", default: 0, null: false
    t.date "planned_start_date"
    t.date "planned_end_date"
    t.date "actual_start_date"
    t.date "actual_end_date"
    t.date "order_date"
    t.date "ship_date"
    t.date "estimated_delivery_date"
    t.date "receipt_date"
    t.date "reminder_date"
    t.boolean "is_reminder", default: true
    t.integer "duration"
    t.string "duration_unit"
    t.decimal "planned_budget", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "actual_budget", precision: 10, scale: 2, default: "0.0", null: false
    t.text "internal_notes"
    t.text "external_notes"
    t.boolean "is_vendor", default: false
    t.boolean "is_complete", default: false
    t.string "image_name"
    t.string "image_url"
    t.string "status"
    t.bigint "user_id"
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["happy_project_id"], name: "index_happy_project_tasks_on_happy_project_id"
    t.index ["id"], name: "index_happy_project_tasks_on_id", unique: true
  end

  create_table "happy_project_teams", force: :cascade do |t|
    t.bigint "happy_project_member_id"
    t.bigint "happy_project_id"
    t.string "team_name"
    t.string "status"
    t.bigint "user_id"
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["happy_project_member_id", "happy_project_id"], name: "by_member_and_project", unique: true
    t.index ["id"], name: "index_happy_project_teams_on_id", unique: true
  end

  create_table "happy_projects", force: :cascade do |t|
    t.bigint "happy_customer_id"
    t.bigint "happy_quote_id"
    t.bigint "happy_project_task_id"
    t.bigint "happy_install_site_id"
    t.bigint "happy_project_manager_id"
    t.integer "position"
    t.string "number"
    t.integer "sub"
    t.string "project_name"
    t.string "description"
    t.string "general_contractor"
    t.string "site_contact_name"
    t.string "site_contact_phone"
    t.string "site_contact_email"
    t.string "project_type"
    t.date "planned_start_date"
    t.date "planned_end_date"
    t.date "actual_start_date"
    t.date "actual_end_date"
    t.date "reminder_date"
    t.boolean "is_reminder", default: false
    t.decimal "planned_budget", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "actual_budget", precision: 10, scale: 2, default: "0.0", null: false
    t.text "internal_notes"
    t.text "external_notes"
    t.boolean "is_general_contractor", default: false
    t.boolean "is_complete", default: false
    t.string "image_name"
    t.string "image_url"
    t.string "status"
    t.bigint "user_id", null: false
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["happy_customer_id"], name: "index_happy_projects_on_happy_customer_id"
    t.index ["happy_project_task_id"], name: "index_happy_projects_on_happy_project_task_id", unique: true
    t.index ["id"], name: "index_happy_projects_on_id", unique: true
    t.index ["project_name"], name: "by_project_name", unique: true
  end

  create_table "happy_quote_lines", id: :serial, force: :cascade do |t|
    t.bigint "happy_quote_id"
    t.string "number"
    t.integer "position", default: 0, null: false
    t.string "product_id"
    t.string "vendor_product_id"
    t.string "customer_product_id"
    t.text "description"
    t.string "color"
    t.string "unit_of_measure"
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.boolean "taxable", default: true
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "shipping_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "list_price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "discount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "msrp_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_line_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "adjustments", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "happy_vendor_id"
    t.string "vendor_name"
    t.decimal "buyout_unit_price", precision: 10, scale: 2, null: false
    t.decimal "margin", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_cost_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.text "internal_notes"
    t.text "external_notes"
    t.decimal "weight", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "purchase_discount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "sell_discount", precision: 10, scale: 2, default: "0.0", null: false
    t.binary "quote_line_image"
    t.string "quote_line_image_url"
    t.string "status"
    t.bigint "user_id"
    t.bigint "user_id_add"
    t.bigint "user_id_update"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_quote_id"], name: "index_happy_quote_lines_on_happy_quote_id"
    t.index ["id", "position"], name: "index_happy_quote_lines_on_id_position"
    t.index ["id"], name: "index_happy_quote_lines_on_id", unique: true
  end

  create_table "happy_quotes", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_customer_id"
    t.string "number"
    t.integer "sub", default: 0, null: false
    t.string "record_type"
    t.date "quote_date"
    t.date "order_date"
    t.string "shipping_method"
    t.string "fob"
    t.string "terms"
    t.date "estimated_ship_date"
    t.date "estimated_delivery_date"
    t.string "shipping_geocode"
    t.float "shipping_lat"
    t.float "shipping_long"
    t.string "shipping_street1"
    t.string "shipping_street2"
    t.string "shipping_city"
    t.string "shipping_state"
    t.string "shipping_zipcode"
    t.string "shipping_county"
    t.boolean "shipaddress_same_billaddress"
    t.decimal "shipping_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "item_total", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "order_subtotal", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "adjustment_total", precision: 10, scale: 2, default: "0.0", null: false
    t.string "state", default: "draft"
    t.string "user_name"
    t.decimal "payment_total", precision: 10, scale: 2, default: "0.0"
    t.string "shipment_state"
    t.string "payment_state"
    t.string "email"
    t.text "special_instructions"
    t.text "internal_notes"
    t.text "external_notes"
    t.string "currency"
    t.decimal "shipment_total", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "tax_rate", precision: 10, scale: 3, default: "0.0"
    t.decimal "additional_tax_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "included_tax_total", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "item_count", default: 0
    t.binary "quote_image"
    t.string "quote_image_url"
    t.datetime "approved_at", precision: nil
    t.string "approver_name"
    t.boolean "confirmation_delivered", default: false
    t.boolean "discount_override", default: false
    t.boolean "tax_override", default: false
    t.string "mailing_street1"
    t.string "mailing_street2"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_zipcode"
    t.boolean "copy", default: false
    t.datetime "canceled_at", precision: nil
    t.integer "canceler_id"
    t.string "status", default: "open"
    t.bigint "user_id"
    t.bigint "user_id_add"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.string "project_title"
    t.index ["happy_customer_id"], name: "index_happy_quotes_on_happy_customer_id"
    t.index ["id"], name: "index_happy_quotes_on_id", unique: true
    t.index ["number"], name: "index_happy_quotes_on_number"
  end

  create_table "happy_reminders", force: :cascade do |t|
    t.string "name"
    t.text "content"
    t.bigint "remindable_id"
    t.string "remindable_type"
    t.string "status"
    t.boolean "is_sent", default: false
    t.date "reminder_date"
    t.bigint "user_id", null: false
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["id"], name: "index_happy_reminders_on_id", unique: true
    t.index ["remindable_type", "remindable_id"], name: "index_happy_reminders_on_remindable_type_and_remindable_id"
    t.index ["reminder_date", "user_id"], name: "index_happy_reminders_on_reminder_date_user_id"
  end

  create_table "happy_site_products", force: :cascade do |t|
    t.bigint "happy_install_site_id"
    t.bigint "happy_vendor_id"
    t.bigint "happy_category_id"
    t.bigint "happy_quote_id"
    t.string "product_name"
    t.string "description"
    t.string "color"
    t.decimal "weight", precision: 10, scale: 3, default: "0.0"
    t.string "product_type"
    t.string "product_id"
    t.date "install_date"
    t.date "install_start_date"
    t.date "install_end_date"
    t.date "warranty_date"
    t.string "warranty"
    t.boolean "isWarranty", default: false
    t.decimal "length", precision: 10, scale: 3, default: "0.0"
    t.decimal "width", precision: 10, scale: 3, default: "0.0"
    t.decimal "height", precision: 10, scale: 3, default: "0.0"
    t.decimal "cubic_feet", precision: 10, scale: 3, default: "0.0"
    t.float "latitude"
    t.float "longitude"
    t.string "image_name"
    t.string "image_url"
    t.string "status"
    t.string "user_id"
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["happy_install_site_id"], name: "index_happy_site_products_on_happy_install_site_id", unique: true
    t.index ["id"], name: "index_happy_site_products_on_id", unique: true
  end

  create_table "happy_standard_activities", force: :cascade do |t|
    t.bigint "happy_standard_task_id"
    t.bigint "happy_customer_id"
    t.bigint "happy_vendor_id"
    t.bigint "happy_task_category_id"
    t.bigint "happy_activity_category_id"
    t.integer "position"
    t.string "activity_name"
    t.string "description"
    t.string "priority"
    t.string "group"
    t.string "dependency", default: [], array: true
    t.bigint "lead_time", default: 0, null: false
    t.boolean "is_vendor", default: false
    t.integer "duration"
    t.string "duration_unit"
    t.string "image_name"
    t.string "image_url"
    t.string "status"
    t.bigint "user_id", null: false
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["activity_name"], name: "index_happy_standard_activities_on_activity_name", unique: true
    t.index ["happy_standard_task_id"], name: "index_happy_standard_activities_on_happy_standard_task_id"
    t.index ["id"], name: "index_happy_standard_activities_on_id", unique: true
  end

  create_table "happy_standard_processes", force: :cascade do |t|
    t.bigint "happy_standard_task_id"
    t.bigint "happy_standard_activity_id"
    t.integer "position"
    t.string "process_name"
    t.string "description"
    t.string "process_type"
    t.string "status"
    t.bigint "user_id", null: false
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["id"], name: "index_happy_standard_processes_on_id", unique: true
    t.index ["process_name"], name: "index_happy_standard_processes_on_process_name", unique: true
  end

  create_table "happy_standard_tasks", force: :cascade do |t|
    t.bigint "happy_customer_id"
    t.bigint "happy_vendor_id"
    t.bigint "happy_standard_activity_id"
    t.bigint "happy_task_category_id"
    t.integer "position"
    t.string "task_name"
    t.string "description"
    t.string "priority"
    t.string "dependency", default: [], array: true
    t.bigint "lead_time", default: 0, null: false
    t.boolean "is_vendor", default: false
    t.string "image_name"
    t.string "image_url"
    t.string "status"
    t.bigint "user_id", null: false
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["id"], name: "index_happy_standard_tasks_on_id", unique: true
    t.index ["task_name"], name: "index_happy_standard_tasks_on_task_name", unique: true
  end

  create_table "happy_task_activities", force: :cascade do |t|
    t.bigint "happy_project_task_id"
    t.bigint "happy_customer_id"
    t.bigint "happy_vendor_id"
    t.bigint "happy_standard_process_id"
    t.bigint "happy_standard_activity_id"
    t.integer "position"
    t.string "activity_name"
    t.string "description"
    t.string "priority"
    t.string "group"
    t.string "dependency", default: [], array: true
    t.bigint "lead_time", default: 0, null: false
    t.date "planned_start_date"
    t.date "planned_end_date"
    t.date "actual_start_date"
    t.date "actual_end_date"
    t.date "order_date"
    t.date "ship_date"
    t.date "estimated_delivery_date"
    t.date "receipt_date"
    t.date "reminder_date"
    t.boolean "is_reminder", default: true
    t.integer "duration"
    t.string "duration_unit"
    t.decimal "planned_budget", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "actual_budget", precision: 10, scale: 2, default: "0.0", null: false
    t.text "internal_notes"
    t.text "external_notes"
    t.boolean "is_vendor", default: false
    t.boolean "is_complete", default: false
    t.string "image_name"
    t.string "image_url"
    t.string "status"
    t.bigint "user_id", null: false
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
    t.index ["happy_project_task_id"], name: "index_happy_task_activities_on_happy_project_task_id"
    t.index ["id"], name: "index_happy_task_activities_on_id", unique: true
  end

  create_table "happy_task_categories", force: :cascade do |t|
    t.string "category_name"
    t.index ["id"], name: "index_happy_task_categories_on_id", unique: true
  end

  create_table "happy_vendor_companies", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.string "company_name"
    t.string "vendor_type"
    t.boolean "taxable", default: true
    t.string "region"
    t.string "business_phone"
    t.string "cell_phone"
    t.string "fax"
    t.string "vendor_geocode"
    t.float "vendor_lat"
    t.float "vendor_long"
    t.string "vendor_street1"
    t.string "vendor_street2"
    t.string "vendor_city"
    t.string "vendor_state"
    t.string "vendor_country"
    t.string "vendor_zipcode"
    t.string "vendor_county"
    t.boolean "minority", default: false
    t.boolean "vendor1099", default: true
    t.string "ap_acct_ref"
    t.string "bank_name"
    t.string "bank_aba"
    t.string "bank_acct_no"
    t.string "vendor_tax_id"
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["company_name"], name: "index_vendor_on_company_name"
    t.index ["happy_company_id"], name: "index_happy_vendor_companies_on_happy_company_id"
  end

  create_table "happy_vendor_pricelists", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_vendor_id"
    t.string "pricelist_name"
    t.string "pricelist_type"
    t.date "received_date"
    t.date "effective_date"
    t.decimal "purchase_discount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "sell_discount", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_vendor_id"], name: "index_happy_vendor_pricelists_on_happy_vendor_id"
  end

  create_table "happy_vendors", force: :cascade do |t|
    t.bigint "happy_company_id", default: 1, null: false
    t.bigint "happy_profit_center_id"
    t.bigint "happy_vendor_company_id"
    t.string "vendor_name"
    t.string "vendor_type"
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.string "title"
    t.string "suffix"
    t.string "email"
    t.string "website"
    t.boolean "taxable", default: true
    t.string "terms"
    t.string "region"
    t.string "home_phone"
    t.string "business_phone"
    t.string "fax"
    t.string "mailing_geocode"
    t.float "mailing_lat"
    t.float "mailing_long"
    t.string "mailing_street1"
    t.string "mailing_street2"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_country"
    t.string "mailing_zipcode"
    t.string "mailing_county"
    t.boolean "minority", default: false
    t.boolean "vendor1099", default: true
    t.string "ap_acct_ref"
    t.string "bank_name"
    t.string "bank_aba"
    t.string "bank_acct_no"
    t.string "vendor_tax_id"
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "user_id"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0
    t.index ["happy_vendor_company_id"], name: "index_happy_vendors_on_happy_vendor_company_id", unique: true
    t.index ["id"], name: "index_happy_vendors_on_id", unique: true
    t.index ["last_name"], name: "index_vendor_on_last_name"
    t.index ["vendor_name"], name: "index_happy_vendors_on_vendor_name", unique: true
    t.index ["vendor_name"], name: "index_vendor_on_vendor_name"
  end

  create_table "hp_products", id: false, force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "happy_category_id"
    t.string "part_number", limit: 20
    t.string "description", limit: 100
    t.decimal "list_price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "weight", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "ipema_certified", default: true
    t.boolean "cpsc_certified", default: true
    t.boolean "csa_certified", default: true
    t.boolean "en_certified", default: true
    t.boolean "astm_certified", default: true
    t.string "user_id_add"
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["part_number"], name: "hp_products_part_number_key", unique: true
  end

  create_table "multiple_indexes", force: :cascade do |t|
  end

  create_table "pw_products_2021_raw", id: false, force: :cascade do |t|
    t.bigserial "id", null: false
    t.string "category"
    t.string "part_number"
    t.string "description"
    t.decimal "list_price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "weight", precision: 10, scale: 2, default: "0.0", null: false
    t.boolean "ipema_certified", default: true
    t.boolean "cpsc_certified", default: true
    t.boolean "csa_certified", default: true
    t.boolean "en_certified", default: true
    t.bigint "happy_categories_id"
    t.string "user_id_add"
    t.string "user_id_update"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.decimal "dealer_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["part_number"], name: "pw_products_2021_raw_key", unique: true
  end

  create_table "pw_repair_parts", force: :cascade do |t|
    t.string "part_number"
    t.string "description"
    t.decimal "weight", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "list_price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "dealer_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.string "pricelist_name"
    t.bigint "user_id_add"
    t.bigint "user_id_update"
    t.boolean "active", default: true
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.boolean "admin", default: false
    t.string "jti"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wabash_2021_parts", force: :cascade do |t|
    t.string "part_number"
    t.string "series"
    t.string "description"
    t.decimal "weight", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "list_price", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "dealer_cost", precision: 10, scale: 2, default: "0.0", null: false
    t.string "pricelist_name"
    t.bigint "user_id_add", default: 1
    t.bigint "user_id_update", default: 1
    t.boolean "active", default: true
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.integer "lock_version", default: 0
  end

  add_foreign_key "happy_categories", "happy_vendors"
  add_foreign_key "happy_customer_companies", "happy_companies"
  add_foreign_key "happy_customers", "happy_customer_companies"
  add_foreign_key "happy_po_lines", "happy_pos"
  add_foreign_key "happy_po_lines", "happy_vendors"
  add_foreign_key "happy_po_receivers", "happy_po_lines"
  add_foreign_key "happy_pos", "happy_companies"
  add_foreign_key "happy_pos", "happy_profit_centers"
  add_foreign_key "happy_pos", "happy_vendors"
  add_foreign_key "happy_products", "happy_categories"
  add_foreign_key "happy_products", "happy_vendor_pricelists", name: "fk_products_pricelist"
  add_foreign_key "happy_profit_centers", "happy_companies"
  add_foreign_key "happy_project_managers", "happy_projects"
  add_foreign_key "happy_project_tasks", "happy_projects"
  add_foreign_key "happy_projects", "happy_customers"
  add_foreign_key "happy_quote_lines", "happy_quotes"
  add_foreign_key "happy_quote_lines", "happy_vendors"
  add_foreign_key "happy_quotes", "happy_companies"
  add_foreign_key "happy_quotes", "happy_customers"
  add_foreign_key "happy_quotes", "happy_profit_centers"
  add_foreign_key "happy_standard_activities", "happy_standard_tasks"
  add_foreign_key "happy_task_activities", "happy_project_tasks"
  add_foreign_key "happy_vendor_companies", "happy_companies"
  add_foreign_key "happy_vendors", "happy_vendor_companies"
end
