class FrontendSessionController < ApplicationController
  before_filter :trusted_frontend

  # GET /frontend_session/new
  # GET /frontend_session/new.xml
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


  # DELETE /frontend_session/1
  # DELETE /frontend_session/1.xml
  def destroy
    @frontend_session = FrontendSession.find(params[:id])
    @frontend_session.destroy

    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end
  end

end
