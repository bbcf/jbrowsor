class CreateFrontendSessions < ActiveRecord::Migration
  def self.up
    create_table :frontend_sessions do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :frontend_sessions
  end
end
