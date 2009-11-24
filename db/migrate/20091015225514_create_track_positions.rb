class CreateTrackPositions < ActiveRecord::Migration
  def self.up
    create_table :track_positions do |t|
      t.integer :position
      t.integer :jbrowse_view_id
      t.integer :track_id		 
      t.timestamps
    end
    execute "ALTER TABLE track_positions ADD CONSTRAINT jbrowse_view_id_fkey_track_positions FOREIGN KEY (jbrowse_view_id) REFERENCES jbrowse_views (id);"
    execute "ALTER TABLE track_positions ADD CONSTRAINT track_id_fkey_track_positions FOREIGN KEY (track_id) REFERENCES tracks (id);"
  end

  def self.down
    execute "ALTER TABLE track_positions DROP CONSTRAINT jbrowse_view_id_fkey_track_positions;"
    execute "ALTER TABLE track_positions DROP CONSTRAINT track_id_fkey_track_positions;"
    drop_table :track_positions
  end
end
