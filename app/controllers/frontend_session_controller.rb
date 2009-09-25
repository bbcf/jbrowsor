class FrontendSessionController < ApplicationController
  before_filter :trusted_frontend

  def new
    @frontend_session = FrontendSession.new
    respond_to do |format|
      if @frontend_session.save
	format.html
	format.xml {render :layout => false}
	format.json {render :layout => false, :json => @frontend_session.id.to_json}
      else
	render :status => 403
      end
    end
  end

end
