class CreateJbrowseViews < ActiveRecord::Migration
  def self.up
    create_table :jbrowse_views do |t|
      t.integer :frontend_session_id
      t.boolean :permanent_public
      t.timestamps
    end
      execute "ALTER TABLE jbrowse_views ADD CONSTRAINT frontend_session_id_fkey FOREIGN KEY (frontend_session_id) REFERENCES frontend_sessions (id);"
  end

  def self.down
    execute "ALTER TABLE jbrowse_views DROP CONSTRAINT frontend_session_id_fkey;"
    drop_table :jbrowse_views
  end
end
