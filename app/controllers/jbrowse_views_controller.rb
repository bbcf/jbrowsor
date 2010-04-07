class JbrowseViewsController < ApplicationController

  # POST /jbrowse_views
  # POST /jbrowse_views.xml
  # preliminary
  def create
     @jbrowse_view = JbrowseView.new(params[:jbrowse_view])

    ### create json

    #    respond_to do |format|
    begin
      @jbrowse_view.save         
      ### create track_positions                                                                                                             
      if @jbrowse_view.track_list != ''
        list_of_track_ids = @jbrowse_view.track_list.split(/\s*,\s*/).select{ |id| id.match(/^\d+$/)}
        list_of_tracks = Track.find(list_of_track_ids)
        
        ### use first track in the list to determine the genome for the whole view and check then homogeneity of tracks regarding to genome
        ref_genome_id = list_of_tracks[0].genome_id
        list_of_tracks.select{|e| e.genome_id == ref_genome_id}.each_index do |i|
          track = list_of_tracks[i]
          track_pos = TrackPosition.new(
                                        :jbrowse_view_id => @jbrowse_view.id, 
                                        :track_id => track.id, 
                                        :position => i
                                        )
          track_pos.save
        end
      end
 
      respond_to do |format|  
        format.html
        format.xml {render :layout => false}
        format.json {
         render :json => { :id => @jbrowse_view.id}.to_json
        }
      end
    rescue Exception => e
      render :text => e.message + '<br/>' + list_of_tracks.to_json
    end
    #    end     
  end
  
  # GET /jbrowse_views/1
  # GET /jbrowse_views/1.xml
  def show
    @jbrowse_view = JbrowseView.find(params[:id])
    @id = params[:id]
    
    ### get track_positions and create json from data                                                                                                          
    jbrowse_data_dir = APP_CONFIG["jbrowse_data"]
    ### take first track to get the genome_id
    cur_genome_id = @jbrowse_view.track_positions[0].track.genome_id

    file = File.new("#{jbrowse_data_dir}/#{cur_genome_id}/data/trackInfo.js")
    #    File.open(file, 'r') {|f| f.read(res) }
    json = IO.readlines(file).join(' ')
    all_data = JSON.parse(json)
#    data = all_data['trackInfo']
#    data = [
#            { 
#              "url" => "data/seq/{refseq}/",
#              "args" => {
#                "chunkSize" => 20000
#              },
#              "label" => "DNA",
#              "type" => "SequenceTrack",
#              "key" => "DNA"
#            }]
    @jbrowse_view.track_positions.each do |tp|
      t = tp.track
      if t.status.name == "success"
        tmp_h={ }
        if (t.data_type.name == "qualitative")
          tmp_h={
            "url" => 'data/tracks/{ refseq}' + "/#{t.base_filename}.json",
            "label" => t.name,
            "type" => "FeatureTrack",
            "key" => t.name
          }
        else
          tmp_h= {
            "url" => 'data/tracks/{ refseq}' + "/#{t.base_filename}/trackData.json",
            "label" => t.name,
            "type" => "ImageTrack",
            "key" => t.name
          }
        end
        all_data['trackInfo'].push(tmp_h)
      end
    end

    file = File.new("#{ jbrowse_data_dir}/#{cur_genome_id}/data/refSeqs.js")
    json = IO.readlines(file).join(' ')
    refseq = JSON.parse(json)
    all_data['refSeqs']=refseq['refSeqs']
#    data = all_data[json]
    

    respond_to do |format|
      format.html # show.html.erb
      format.js { render :json => all_data.to_json}# show.js.rjs
    end
  end

end
