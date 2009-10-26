class Genome < ActiveRecord::Base

  belongs_to :statuses

  has_many :tracks
  has_one :job, :as => :runnable

  ### ADD validation presence_of for frontend_session_id
  validates_presence_of :name, :tax_id, :species, :chr_list, :url
  ### ADD validation numericality for frontend_session_id 
  validates_numericality_of :tax_id
  validates_format_of :url, :with => %r{^(http|ftp)://.+$}i,
  :message => "must be a valid url."
 
  protected

end
