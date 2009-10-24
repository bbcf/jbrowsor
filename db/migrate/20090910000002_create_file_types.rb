class CreateFileTypes < ActiveRecord::Migration
  def self.up
    create_table :file_types do |t|
      t.string :extension
    end
  end

  def self.down
   drop_table :file_types
  end
end
