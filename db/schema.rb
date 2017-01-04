@@ -11,7 +11,7 @@
  #
  # It's strongly recommended that you check this file into your version control system.
  
 -ActiveRecord::Schema.define(version: 20161123101856) do
 +ActiveRecord::Schema.define(version: 20160909105514) do
  
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
 @@ -29,10 +29,8 @@
      t.string   "course_time"
      t.string   "course_week"
      t.integer  "teacher_id"
 -    t.datetime "created_at",                    null: false
 -    t.datetime "updated_at",                    null: false
 -    t.boolean  "open"
 -    t.boolean  "course_open",   default: false
 +    t.datetime "created_at",                null: false
 +    t.datetime "updated_at",                null: false
    end
  
    create_table "grades", force: :cascade do |t|