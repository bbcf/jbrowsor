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

ActiveRecord::Schema.define(:version => 20091015225514) do

  create_table "data_types", :force => true do |t|
    t.string "name"
  end

  create_table "file_types", :force => true do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "frontend_sessions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genomes", :force => true do |t|
    t.string   "name"
    t.integer  "tax_id"
    t.string   "species"
    t.text     "chr_list"
    t.integer  "frontend_session_id"
    t.integer  "status_id"
    t.text     "url"
    t.boolean  "public",              :default => true
    t.text     "error_log"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "genomes", ["frontend_session_id"], :name => "frontend_session_id_fkey_genomes"
  add_index "genomes", ["status_id"], :name => "status_id_fkey_genomes"

  create_table "jbrowse_views", :force => true do |t|
    t.integer  "frontend_session_id"
    t.boolean  "permanent_public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jbrowse_views", ["frontend_session_id"], :name => "frontend_session_id_fkey_jbrowse_views"

  create_table "jobs", :force => true do |t|
    t.integer  "runnable_id"
    t.string   "runnable_type"
    t.boolean  "running"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.string "name"
  end

  create_table "track_positions", :force => true do |t|
    t.integer  "position"
    t.integer  "jbrowse_view_id"
    t.integer  "track_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "track_positions", ["jbrowse_view_id"], :name => "jbrowse_view_id_fkey_track_positions"
  add_index "track_positions", ["track_id"], :name => "track_id_fkey_track_positions"

  create_table "tracks", :force => true do |t|
    t.text     "name"
    t.integer  "genome_id"
    t.integer  "file_type_id"
    t.integer  "data_type_id"
    t.text     "url"
    t.text     "jbrowse_params"
    t.integer  "status_id"
    t.text     "base_filename"
    t.text     "error_log"
    t.boolean  "strand_plus"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracks", ["data_type_id"], :name => "data_type_id_fkey_tracks"
  add_index "tracks", ["file_type_id"], :name => "file_type_id_fkey_tracks"
  add_index "tracks", ["genome_id"], :name => "genome_id_fkey_tracks"
  add_index "tracks", ["status_id"], :name => "status_id_fkey_tracks"

end
