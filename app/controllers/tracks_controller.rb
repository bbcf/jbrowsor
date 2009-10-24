class TracksController < ApplicationController

  # GET /tracks
  # GET /tracks.xml
  def new
     @track = Track.new
  end

  # POST /tracks
  # POST /tracks.xml
  def create
     @track = Track.new(params)
    respond_to do |format|
      if @track.save
        format.html
        format.xml {render :layout => false}
        format.json {render :layout => false, :json => @track.id.to_json}
      else
        render :status => 403
      end
    end
  end


end
