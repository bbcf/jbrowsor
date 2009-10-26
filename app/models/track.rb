class Track < ActiveRecord::Base
  
  belongs_to :genome
  belongs_to :statuses
  belongs_to :data_types
  belongs_to :file_types
  has_many :views, :through => :track_positions
  has_many :track_positions
  
  has_one :job, :as => :runnable
  
  validates_presence_of :name, :genome_id, :file_type_id, :data_type_id, :url
  validates_uniqueness_of :base_filename
  validate :valid_genome_id
  validate :valid_file_type_id
  validate :valid_data_type_id
  validates_numericality_of :genome_id, :file_type_id, :data_type_id
  validates_format_of :url, :with => %r{^(http|ftp)://.+$}i,
  :message => "must be a valid url." 
  
  
  protected 
  
  def valid_genome_id
    begin
      Genome.find(genome_id, :joins => "join statuses on (status_id=statuses.id)",  :conditions => ["statuses.name = ?", "success"])
    rescue Exception => e
      errors.add(:genome_id, "is not a valid genome ID: #{e.message}")
    end
  end
  
  def valid_file_type_id
    begin
      FileType.find(file_type_id)
    rescue Exception => e
      errors.add(:file_type_id, 'is not a valid file type ID: #{e.message}')
    end
  end
  
  def valid_data_type_id
    begin
      DataType.find(data_type_id)
    rescue Exception => e
      errors.add(:data_type_id, 'is not a valid data type ID: #{e.message}')
    end
  end
  
end
