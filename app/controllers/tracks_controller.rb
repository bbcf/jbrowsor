class TracksController < ApplicationController

  # GET /track
  # GET /track.xml
  def new
     @track = Track.new
  end

  # POST /track
  # POST /track.xml
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
