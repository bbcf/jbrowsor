class JbrowseViewController < ApplicationController
  # POST /jbrowse_view
  # POST /jbrowse_view.xml
  def create
     
  end

  # GET /jbrowse_view/1
  # GET /jbrowse_view/1.xml
  def show
    @jbrowse_view = JbrowseView.find(params[:id])
    # Todo: write code to display view
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :layout => false }
    end
  end

end
