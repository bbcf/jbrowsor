class Genome < ActiveRecord::Base

  has_many :tracks
  has_one :job, :as => :runnable

end
