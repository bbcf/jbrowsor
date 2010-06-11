module TrackHelper
  def genome_selection(form)
    genomes = Genome.find(:all, :order => "name", :conditions =>[ "hidden = false"]).map{|g| [g.name, g.id]}
    form.select(:genome_id, genomes)
  end

  def data_types
    DataType.find(:all, :order => "name").map{|dt| [dt.name, dt.id]}
  end

  def file_types
    FileType.find(:all, :order => "name").map{|ft| [ft.name, ft.id]}
  end
end
