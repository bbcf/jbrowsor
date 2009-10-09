class FrontendSession < ActiveRecord::Base
  has_many :jbrowse_view, :dependent => :destroy
end
