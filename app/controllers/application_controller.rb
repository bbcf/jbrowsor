# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details
#  protect_from_forgery :only => [:create, :update, :destroy] 

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def trusted_frontend
#    $stderr.puts "REQUEST IP >>>>>>>>>>>>>>> #{request.remote_ip}"
#    $stderr.puts "TRUSTED LIST >>>>>>>>>>>>> #{APP_CONFIG["trusted_frontend_ip"].join(', ')}"
#    $stderr.puts "IN LIST >>>>>>>>>>>>>>>>>> #{APP_CONFIG["trusted_frontend_ip"].include? request.remote_ip}"
    unless APP_CONFIG["trusted_frontend_ip"].include? request.remote_ip
      render :file => "#{RAILS_ROOT}/public/403.html", :status => '403 Forbidden'
    end
  end

end
