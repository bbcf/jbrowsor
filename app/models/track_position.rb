 class TrackPosition < ActiveRecord::Base

belongs_to :jbrowse_view
acts_as_list :scope => :jbrowse_view

belongs_to :track

end
