require 'active_record/fixtures'

class CreateDataTypes < ActiveRecord::Migration
  def self.up
    create_table :data_types do |t|
      t.string :name
    end

    directory = Rails.root + "db" + "seed_data"
    Fixtures.create_fixtures(directory, "data_types")
  end

  def self.down
   drop_table :data_types
  end
end
