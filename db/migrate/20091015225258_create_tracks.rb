class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.text :name
      t.integer :genome_id
      t.integer :file_type_id
      t.integer :data_type_id
      t.text :url
      t.text :jbrowse_params
      t.integer :status_id
      t.text :base_filename
      t.text :error_log
      t.boolean :strand_plus
      t.timestamps
    end
    execute "ALTER TABLE tracks ADD CONSTRAINT genome_id_fkey_tracks FOREIGN KEY (genome_id) REFERENCES genomes (id);"
    execute "ALTER TABLE tracks ADD CONSTRAINT file_type_id_fkey_tracks FOREIGN KEY (file_type_id) REFERENCES file_types (id);"
    execute "ALTER TABLE tracks ADD CONSTRAINT data_type_id_fkey_tracks FOREIGN KEY (data_type_id) REFERENCES data_types (id);"
    execute "ALTER TABLE tracks ADD CONSTRAINT status_id_fkey_tracks FOREIGN KEY (status_id) REFERENCES statuses (id);"
  end

  def self.down
    execute "ALTER TABLE tracks DROP CONSTRAINT genome_id_fkey_tracks;"
    execute "ALTER TABLE tracks DROP CONSTRAINT file_type_id_fkey_tracks;"
    execute "ALTER TABLE tracks DROP CONSTRAINT data_type_id_fkey_tracks;"
    execute "ALTER TABLE tracks DROP CONSTRAINT status_id_fkey_tracks;"
    drop_table :tracks
  end
end
