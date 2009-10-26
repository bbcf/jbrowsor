class TracksController < ApplicationController

require 'digest/sha1'
  
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
    @track.base_filename =  Digest::SHA1.hexdigest(@track.url.to_s).crypt("7hs2ke")
    respond_to do |format|
      if @track.save
        Job.new(
                :runnable_type => "Track",
                :runnable_id   => @track.id,
                :running       => false
                ).save        
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
