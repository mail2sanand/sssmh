# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120608073058) do

  create_table "assets", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "location_name",                        :null => false
    t.string   "location_address"
    t.integer  "day_of_the_month"
    t.binary   "location_map",     :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletters", :force => true do |t|
    t.string   "name"
    t.string   "newsletter_path"
    t.string   "year"
    t.string   "month"
    t.string   "volume"
    t.string   "issue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "role",             :null => false
    t.string   "role_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "programme_name"
    t.string   "location_id"
    t.string   "other_locations"
    t.string   "specializations"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specializations", :force => true do |t|
    t.string   "name",                :null => false
    t.string   "description"
    t.string   "specialization_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_professional_details", :primary_key => "user_professional_detail_id", :force => true do |t|
    t.integer "user_id"
    t.string  "designation",                                        :null => false
    t.string  "specialization",                      :limit => 150, :null => false
    t.string  "qualification",                       :limit => 100, :null => false
    t.string  "institution_name",                                   :null => false
    t.string  "type_of_practice",                    :limit => 100, :null => false
    t.string  "medical_registration_number",         :limit => 150, :null => false
    t.string  "reporting_authority_and_designation"
    t.string  "working_dept"
    t.string  "years_of_exp",                        :limit => 50,  :null => false
    t.boolean "research_interest"
    t.string  "research_details"
    t.string  "papers_published"
    t.boolean "special_training"
    t.string  "special_training_details"
    t.boolean "special_conf_attended"
    t.string  "special_conf_attended_details"
    t.boolean "own_clinic_or_hospital"
    t.string  "treatments_offered"
    t.string  "equipments_available"
    t.integer "beds_count"
    t.string  "certificate_file_name"
    t.string  "certificate_content_type"
    t.integer "certificate_file_size"
  end

  add_index "user_professional_details", ["user_id"], :name => "fk_user_professional_details_user_id"

  create_table "user_ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "doctors_qualification_rating"
    t.integer  "qualification_from_which_institution_rating"
    t.integer  "years_of_experience_rating"
    t.integer  "type_of_practice_rating"
    t.integer  "research_interest_rating"
    t.integer  "voluntary_medical_activity_in_24_months_rating"
    t.integer  "own_a_hospital_rating"
    t.integer  "residing_distance_from_puttaparthi_rating"
    t.integer  "referred_by_existing_doctor_rating"
    t.integer  "total_rating"
    t.integer  "admin_override_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_ratings", ["user_id"], :name => "fk_user_ratings_user_id"

  create_table "user_schedules", :force => true do |t|
    t.integer  "user_id"
    t.integer  "schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "invited"
    t.integer  "volunteered", :default => 1
    t.integer  "approved",    :default => 0
  end

  add_index "user_schedules", ["schedule_id"], :name => "fk_user_schedules_schedule_id"
  add_index "user_schedules", ["user_id"], :name => "fk_user_schedules_user_id"

  create_table "users", :primary_key => "user_id", :force => true do |t|
    t.string   "login",                       :limit => 30,                          :null => false
    t.string   "email",                                                              :null => false
    t.string   "crypted_password",            :limit => 40,                          :null => false
    t.string   "salt",                        :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "gender",                                                             :null => false
    t.integer  "age",                                                                :null => false
    t.string   "full_name",                                                          :null => false
    t.string   "address"
    t.boolean  "sss_org_association"
    t.string   "sss_org_association_details"
    t.string   "contact_mob_no",                                                     :null => false
    t.string   "contact_home_no"
    t.string   "possible_freq_of_visit"
    t.string   "possible_duration_of_visit"
    t.binary   "photo",                       :limit => 16777215
    t.boolean  "volunteer_activity"
    t.string   "volunteer_activity_details"
    t.string   "residing_disance_from_ptp"
    t.boolean  "doctors_referral"
    t.string   "comments"
    t.boolean  "approved",                                        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "user_role",                                       :default => 2,     :null => false
  end

end
