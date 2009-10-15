class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.text :name
      t.integer :genome_id
      t.integer :file_type
      t.integer :data_type
      t.text :url
      t.text :jbrowse_params
      t.integer :status
      t.text :base_filename
      t.timestamps
    end
    execute "ALTER TABLE tracks ADD CONSTRAINT genome_id_fkey FOREIGN KEY (genome_id) REFERENCES genomes (id);"

  end

  def self.down
      execute "ALTER TABLE tracks DROP CONSTRAINT genome_id_fkey;"
    drop_table :tracks
  end
end
