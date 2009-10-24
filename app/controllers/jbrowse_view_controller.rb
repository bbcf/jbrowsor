class JbrowseViewController < ApplicationController

  # POST /jbrowse_view
  # POST /jbrowse_view.xml
  # preliminary
  def create
     @jbrowse_view = JbrowseView.new(params)
    respond_to do |format|
      if @jbrowse_view.save
        format.html
        format.xml {render :layout => false}
        format.json {render :layout => false, :json => @jbrowse_view.id.to_json}
      else
        render :status => 403
      end
    end     
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
