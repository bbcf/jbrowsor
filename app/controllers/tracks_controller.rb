class TracksController < ApplicationController
  
  # GET /tracks
  # GET /tracks.xml
  def new
     @track = Track.new
  end

  # POST /tracks
  # POST /tracks.xml
  def create
    @track = Track.new(params[:track])
    @track.status_id = Status.find(:first, :conditions=>["name = ?", 'pending'])
    respond_to do |format|
      if @track.save
        
        format.html
        #        format.xml {render :layout => false}
        format.json {
          render :layout => false, 
          :json => {:id => @track.id}.to_json
        }
      else
        format.html {render :action => :new} #, :status => 403
        format.json {
          render :layout => false, 
          :json => {:errors => @track.errors}.to_json
        }
      end
    end
  end


end
