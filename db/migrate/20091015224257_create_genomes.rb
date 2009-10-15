class CreateGenomes < ActiveRecord::Migration
  def self.up
    create_table :genomes do |t|
      t.string :name
      t.integer :tax_id
      t.string :species 		     
      t.timestamps
    end
  end

  def self.down
    drop_table :genomes
  end
end
