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
    fields=['id', 'status_id','error_log'] 

    @h_track = {}
    if params[:format]=='json' || params[:format]=='yaml'
      fields.map{|f| @h_track[f] = eval("@track.#{f}")}
    end
    
    respond_to do |format|
      #      format.html # index.html.erb                     
      #      format.xml  {   render :xml => @tracks }
      format.csv  { 
        @buf = fields.join(',') + "\n"
        row=fields.map{|f| eval("@track.#{f}.to_s")}
        CSV.generate_row(row, fields.size, @buf)
        render :csv => @buf 
      }
      format.yaml { 
        render :yaml => @h_track 
      }
      format.json { 
        render :json => @h_track
      }
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
    rnd_string = random_string(10)
    while(Track.find(:first, :conditions=>["base_filename = ?", rnd_string]))
      rnd_string = random_string(10)
    end
    @track.base_filename = rnd_string 
#Digest::SHA1.hexdigest(@track.url.to_s + strand_plus).crypt("7hs2ke").sub(/[\\]/, 'a1').sub(/[\/]/, 'a2')
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

  def  random_string(nber_char)
    s=''
    (1..nber_char).to_a.each do |e|
      n = rand(61)
      c=''
      if (n<10)
        n+=48
        c=n.chr
      elsif (n<36)
#        n+=65
        c=(65+n-10).chr
      else
        c=(97+n-36).chr
#        c=n.chr
      end      
      s+=c
    end
    return s
  end

end
