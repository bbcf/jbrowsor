class Track < ActiveRecord::Base

belongs_to :genome
has_many :views, :through => :track_positions
has_many :track_positions

end
