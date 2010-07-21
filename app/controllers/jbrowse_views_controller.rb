class JbrowseViewsController < ApplicationController

  ### Json parsing                                  
  require 'fileutils'

  # POST /jbrowse_views
  # POST /jbrowse_views.xml
  # preliminary

   def create
     @jbrowse_view = JbrowseView.new(params[:jbrowse_view])

    ### create json

    #    respond_to do |format|
    begin
      @jbrowse_view.save         

      jbrowse_data_dir = APP_CONFIG["jbrowse_data"]

      ### create directory and symbolic links for the view
      jbrowse_view_dir=Pathname.new(APP_CONFIG['jbrowse_views']) + @jbrowse_view.id.to_s
      Dir.mkdir(jbrowse_view_dir)
      jbrowse_view_data_dir=jbrowse_view_dir + 'data'
      Dir.mkdir(jbrowse_view_data_dir)
   
      ### create track_positions       
      if @jbrowse_view.track_list != ''
        list_of_track_ids = @jbrowse_view.track_list.split(/\s*,\s*/).select{|id| id.match(/^\d+$/)}
        list_of_tracks = Track.find(list_of_track_ids)
        
        ### use first track in the list to determine the genome for the whole view and check then homogeneity of tracks regarding to genome
        cur_genome_id = list_of_tracks[0].genome_id
        list_of_tracks.select{|e| e.genome_id == cur_genome_id}.each_with_index do |track, i|
          track_pos = TrackPosition.new(
                                        :jbrowse_view_id => @jbrowse_view.id, 
                                        :track_id => track.id, 
                                        :position => i
                                        )
          track_pos.save
        end
        
        ### create symlinks
        #        genome_data_dir = Pathname.new(RAILS_ROOT) + "public" + "jbrowse" + "data" + cur_genome_id.to_s + "data"
        genome_data_dir = Pathname.new(jbrowse_data_dir) + cur_genome_id.to_s + "data"
        ["tracks","tiles", "seq", "refSeqs.js"].each do |rep|
          File.symlink(genome_data_dir + rep, jbrowse_view_data_dir + rep)
        end 

        ### copy the view directory to a temp dir => to prevent a direct access to trackInfo.js
        tmp_dir = jbrowse_view_dir.to_s + "_temporary87465837465837465"
        FileUtils.cp_r jbrowse_view_data_dir, tmp_dir

        ### create trackInfo.js        
        source_file =  File.new("#{jbrowse_data_dir}/#{cur_genome_id}/data/trackInfo.js")
        trackInfo = generate_trackInfo(source_file, @jbrowse_view)
        File.open("#{tmp_dir}/trackInfo.js", 'w') {|f| f.write("trackInfo = \n" + trackInfo.to_json) }
        
        ### run generate_names.pl
        #        Dir.chdir("#{tmp_dir}") do
        #          jbrowse_bin_dir = Pathname.new(RAILS_ROOT) + "jbrowse/bin/"
        #          cmd = "#{jbrowse_bin_dir}/generate-names.pl --dir ./"
        #          puts cmd + "\n"
        #          output = `#{cmd}`
        #        end
	system "touch #{tmp_dir}/names"
        
        ### mv names and remove temporary dir
        FileUtils.mv tmp_dir + "/names", jbrowse_view_data_dir
        FileUtils.cp "#{tmp_dir}/trackInfo.js", jbrowse_view_data_dir
        FileUtils.rm_r tmp_dir
        FileUtils.rm jbrowse_view_data_dir + "refSeqs.js" ##  no need
      end
 
      respond_to do |format|  
        format.html # missing template
        format.xml {render :layout => false}
        format.json {
         render :json => { :id => @jbrowse_view.id}.to_json
        }
      end
    rescue Exception => e
      render :text => e.message + '<br/>' + list_of_track_ids.to_json
    end
    #    end     
  end

  def generate_trackInfo(source_file, view)
  
    ### retrieve first element of the trackInfo file generated when creating the genome
    json = source_file.readlines.join(' ')
    json.gsub!(/^\s*trackInfo\s*=\s*/,'')
    trackInfo = []
    trackInfo.push(ActiveSupport::JSON.decode(json)[0])

    ### get track_positions    
    view.track_positions.each do |tp|
      t = tp.track
      if t.status.name == "success"
        tmp_h={ }
        if (t.data_type.name == "quantitative")
          tmp_h={
            "url" => 'data/tracks/{refseq}' + "/#{t.base_filename}.json",
            "label" => t.base_filename,
            "type" => "ImageTrack",
            "key" => t.name
          }
            else
          tmp_h= {
            "url" => 'data/tracks/{refseq}' + "/#{t.base_filename}/trackData.json",
            "label" => t.base_filename,
            "type" => "FeatureTrack",
            "key" => t.name
          }
        end
        trackInfo.push(tmp_h)
      end
    end
    return trackInfo;
  end
  
  # GET /jbrowse_views/1
  # GET /jbrowse_views/1.xml
  def show
    @jbrowse_view = JbrowseView.find(params[:id])
    @id = params[:id]
    
    jbrowse_data_dir = APP_CONFIG["jbrowse_data"]
    jbrowse_view_dir=Pathname.new(APP_CONFIG['jbrowse_views']) + @jbrowse_view.id.to_s

    ### take first track to get the genome_id                                                                       
    cur_genome_id = @jbrowse_view.track_positions[0].track.genome_id
    
    all_data={ 
      'var browserRoot'  => APP_CONFIG['browserRoot'] || "/jbrowse/",
      'var dataRoot'     => (APP_CONFIG['dataRoot'] && (APP_CONFIG['dataRoot'] + "#{@jbrowse_view.id}/")) || "/jbrowse/views/#{@jbrowse_view.id}/"     #"/jbrowse/data/#{cur_genome_id}/"
    }

    file = File.new("#{jbrowse_view_dir}/data/trackInfo.js")
    json = file.readlines.join(' ')
    json.gsub!(/^\s*trackInfo\s*=\s*/,'')  
    source_file =  File.new("#{jbrowse_data_dir}/#{cur_genome_id}/data/trackInfo.js")
    all_data['trackInfo']=generate_trackInfo(source_file, @jbrowse_view)

    file = File.new("#{jbrowse_data_dir}/#{cur_genome_id}/data/refSeqs.js")
    json = file.readlines.join(' ')
    json.gsub!(/^\s*refSeqs\s*=\s*/,'')
    all_data['refSeqs']=ActiveSupport::JSON.decode(json)
    
    respond_to do |format|
      format.html # show.html.erb
      format.js { 
        render :json => 
        all_data.keys.map{|k| 
          "#{k} = #{all_data[k].to_json};"}. join("\n")
      }# show.js.rjs
    end
  end
  
end
