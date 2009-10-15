class CreateTrackPositions < ActiveRecord::Migration
  def self.up
    create_table :track_positions do |t|
      t.integer :position
      t.integer :jbrowse_view_id
      t.integer :track_id		 
      t.timestamps
    end
    execute "ALTER TABLE track_positions ADD CONSTRAINT jbrowse_view_id_fkey FOREIGN KEY (jbrowse_view_id) REFERENCES jbrowse_views (id);
ALTER TABLE track_positions ADD CONSTRAINT track_id_fkey FOREIGN KEY (track_id) REFERENCES tracks (id);
"
  end

  def self.down
  execute "ALTER TABLE track_positions DROP CONSTRAINT jbrowser_view_id_fkey;
  ALTER TABLE track_positions DROP CONSTRAINT track_id_fkey;"
    drop_table :track_positions
  end
end
