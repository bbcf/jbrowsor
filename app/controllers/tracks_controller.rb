require "csv"

class TracksController < ApplicationController

require 'digest/sha1'
  
  # GET /tracks
  # GET /tracks.xml
  def new
    @track = Track.new
    @genomes = Genome.find(:all, :order => "name", :conditions =>[ "hidden = false"]).map{|g| [g.name, g.id]}
    @data_types = DataType.find(:all, :order => "name").map{|dt| [dt.name, dt.id]}
    @file_types =  FileType.find(:all, :order => "name").map{|ft| [ft.name, ft.id]}
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

  # POST /tracks/gdv_query
  def gdv_query
    require "sqlite3"
    if params[:id]
      case params[:id]
      when "db_scores"
        db_param = String.new params[:db]
        genome_id = Track.find_by_base_filename(db_param.sub(/\/.*/,"")).genome.id
        render_string = String.new db_param
        params[:imgs].split(",").map{|e| e.to_i}.each do |img_num|
          dbfile = (Pathname.new(APP_CONFIG['jbrowse_data']) + genome_id.to_s + 'data' + 'tracks' + db_param).to_s
          render_string << "$#{img_num}={"
          SQLite3::Database.open(dbfile) do |db|
            render_string << db.execute("select pos,score from sc where number=? order by pos asc", img_num).map{|score_entry| score_entry.join(':') }.join(',')
          end # SQLite3::Database
          render_string << "}"
        end # img_num
        render :text => render_string
      else
        raise "gdv_query: Unknown message id"
      end #case params[:id]
    end
  end

  # POST /tracks/gdv_conversion_done
  def gdv_conversion_done
    if params[:id]
      case params[:id]
      when "track_status" # deal with feedback from compute_to_sqlite daemon
	if params[:mess]=="completed"
	  t = Track.find_by_id(params[:track_id])
	  t.update_attribute(:status, Status.find_by_name("success")) if t
	end
      when "track_error" # deal with error from transform_to_sqlite daemon 
	t = Track.find_by_id(params[:track_id])
	t.update_attribute(:status, Status.find_by_name("failure")) if t 
	#TODO get error message
      when "track_parsing_success" # deal with success from transform_to_sqlite daemon
	t = Track.find_by_id(params[:track_id])
	t.update_attribute(:status, Status.find_by_name("success")) if t 
      end # case params[:id]
    end if params[:id]
    render :nothing => true
  end

  private
  def random_string(nber_char)
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
