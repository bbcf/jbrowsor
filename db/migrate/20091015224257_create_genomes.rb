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
      t.timestamps
    end
        execute "ALTER TABLE genomes ADD CONSTRAINT frontend_session_id_fkey FOREIGN KEY (frontend_session_id) REFERENCES frontend_sessions (id);
ALTER TABLE genomes ADD CONSTRAINT status_id_fkey FOREIGN KEY (status_id) REFERENCES statuses (id); 
" 
  end

  def self.down
     execute "ALTER TABLE genomes DROP CONSTRAINT frontend_session_id_fkey;  
   ALTER TABLE genomes DROP CONSTRAINT status_id_fkey;
";
    drop_table :genomes
  end
end
