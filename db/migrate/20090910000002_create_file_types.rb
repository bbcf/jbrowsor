require 'active_record/fixtures'

class CreateFileTypes < ActiveRecord::Migration
  def self.up
    create_table :file_types do |t|
      t.string :name
      t.text :description
    end

    directory = Rails.root + "db" + "seed_data"
    Fixtures.create_fixtures(directory, "file_types")
  end

  def self.down
   drop_table :file_types
  end
end
