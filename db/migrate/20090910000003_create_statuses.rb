require 'active_record/fixtures'

class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :name
    end

    directory = Rails.root + "db" + "seed_data"
    Fixtures.create_fixtures(directory, "statuses")
  end

  def self.down
    drop_table :statuses
  end
end
