require "csv"

class TracksController < ApplicationController

require 'digest/sha1'
  
  # GET /tracks
  # GET /tracks.xml
  def new
     @track = Track.new
  end

  def show
    @track = Track.find(params[:id])
    fields=['id', 'status_id','error_log'] #'name','genome_id', 'file_type_id', 'data_type_id', 'url', 'jbrowse_params', 'status_id', 'base_filename', 'error_log', 'strand_plus','created_at','updated_at']
    @buf = fields.join(',') + "\n"
    row=fields.map{|f| eval("@track.#{f}.to_s")}
    CSV.generate_row(row, fields.size, @buf)
    
    respond_to do |format|
#      format.html # index.html.erb                     
#      format.xml  {   render :xml => @tracks }
      format.csv  {   render :csv => @buf }
    end
  end

  # POST /tracks
  # POST /tracks.xml
  def create
    @track = Track.new(params[:track])
    @track.status_id = Status.find(:first, :conditions=>["name = ?", 'pending'])
    strand_plus=''
    if @track.strand_plus
      strand_plus = (@track.strand_plus == true) ? 't' : 'f' 
    end
    @track.base_filename =  Digest::SHA1.hexdigest(@track.url.to_s + strand_plus).crypt("7hs2ke").sub(/[\\]/, 'a1').sub(/[\/]/, 'a2')
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
