class CreateDataTypes < ActiveRecord::Migration
  def self.up
    create_table :data_types do |t|
      t.string :name
    end
  end

  def self.down
   drop_table :data_types
  end
end
