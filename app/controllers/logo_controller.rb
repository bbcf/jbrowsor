class LogoController < ApplicationController

  # GET /logo/1
  def show
    begin
      @frontend_session = FrontendSession.find(params[:id])
      session['frontend_session'] = @frontend_session
      render :file => "#{RAILS_ROOT}/public/JbrowsoR_Logo.png"
    rescue ActiveRecord::RecordNotFound
      render :file => "#{RAILS_ROOT}/public/Oops_Logo.png"
    end
  end


end
