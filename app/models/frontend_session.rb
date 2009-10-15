class FrontendSession < ActiveRecord::Base
  has_many :jbrowse_views, :dependent => :destroy
end
