class CreateGenomes < ActiveRecord::Migration
  def self.up
    create_table :genomes do |t|
      t.string :name
      t.integer :tax_id
      t.string :species
      t.text :chr_list
      t.integer :frontend_session_id
      t.integer :status_id
      t.text :url
      t.boolean :public, :default => true
      t.text :error_log
      t.timestamps
    end
    execute "ALTER TABLE genomes ADD CONSTRAINT frontend_session_id_fkey_genomes FOREIGN KEY (frontend_session_id) REFERENCES frontend_sessions (id);"
    execute "ALTER TABLE genomes ADD CONSTRAINT status_id_fkey_genomes FOREIGN KEY (status_id) REFERENCES statuses (id);" 
  end

  def self.down
    execute "ALTER TABLE genomes DROP CONSTRAINT frontend_session_id_fkey_genomes;"
    execute "ALTER TABLE genomes DROP CONSTRAINT status_id_fkey_genomes;"
    drop_table :genomes
  end
end
