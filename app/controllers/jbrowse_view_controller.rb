class JbrowseViewController < ApplicationController
  # POST /jbrowse_view
  # POST /jbrowse_view.xml
  def create
     
  end

  # GET /jbrowse_view/1
  # GET /jbrowse_view/1.xml
  def show
    @jbrowse_view = JbrowseView.find(params[:id])
    @id = params[:id]
    respond_to do |format|
      format.html # show.html.erb
      format.js # show.js.rjs
    end
  end

end
