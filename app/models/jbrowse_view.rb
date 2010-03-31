class JbrowseView < ActiveRecord::Base

  belongs_to :frontend_session
  has_many :track_positions, :order => :position

  attr_accessor :track_list
  

end
