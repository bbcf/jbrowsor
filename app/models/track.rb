class Track < ActiveRecord::Base
  
  belongs_to :genome
  belongs_to :statuses
  belongs_to :data_types
  belongs_to :file_types
  has_many :views, :through => :track_positions
  has_many :track_positions
  
  has_one :job, :as => :runnable
  
  validates_presence_of :name, :genome_id, :file_type_id, :data_type_id, :url
  validate :valid_genome_id
  validate :valid_file_type_id
  validate :valid_data_type_id
  validates_numericality_of :genome_id, :file_type_id, :data_type_id
  validates_format_of :url, :with => %r{^(http|ftp)://.+$}i,
  :message => "must be a valid url." 
  
  
  protected 
  
  def valid_genome_id
    begin
      Genome.find(genome_id)
    rescue
      errors.add(:genome_id, 'is not a valid genome ID')
    end
  end
  
  def valid_file_type_id
    begin
      FileType.find(file_type_id)
    rescue
      errors.add(:file_type_id, 'is not a valid file type ID')
    end
  end
  
  def valid_data_type_id
    begin
      DataType.find(data_type_id)
    rescue
      errors.add(:data_type_id, 'is not a valid data type ID')
    end
  end
  
end
