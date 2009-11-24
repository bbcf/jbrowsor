class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :runnable_id
      t.string  :runnable_type
      t.boolean :running		 
      t.timestamps
    end
#    execute "ALTER TABLE jobs ADD CONSTRAINT track_id_fkey_jobs FOREIGN KEY (track_id) REFERENCES tracks (id);"

  end

  def self.down
#    execute "ALTER TABLE jobs DROP CONSTRAINT track_id_fkey_jobs;"
    drop_table :jobs
  end
end
