module JbrowseViewHelper
  def track_info
    # TODO Generate correct output once JbrowseView is able to correctly access it's track members
    # info = [] = @jbrowse_view.tracks.map do |track| ....
    
    info = [{"args"=>{"chunkSize"=>20000}, "type"=>"SequenceTrack", "url"=>"data/seq/{refseq}/", "key"=>"DNA", "label"=>"DNA"}]

    info
  end
end
