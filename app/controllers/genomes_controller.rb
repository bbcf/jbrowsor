require "csv"

class GenomesController < ApplicationController

  def index
    @genomes = Genome.find(:all, :conditions => ["public is ?", 'true'])
    fields=['id', 'name','tax_id', 'species', 'url', 'chr_list', 'status_id', 'error_log', 'created_at', 'updated_at']
    @buf = fields.join(',') + "\n"
    @genomes.each do |g|
      row=fields.map{|f| eval("g.#{f}.to_s")} 
      CSV.generate_row(row, fields.size, @buf)
    end
    respond_to do |format|
#      format.html # index.html.erb
#      format.xml  {  render :xml => @genomes }
      format.csv  {  render :csv => @buf }
    end
  end

  def show
    @genome = Genome.new
    fields=['id', 'status_id','error_log'] 
    @buf = fields.join(',') + "\n"
    row=fields.map{|f| eval("@genome.#{f}.to_s")}
    CSV.generate_row(row, fields.size, @buf)

    respond_to do |format|
      format.html # index.html.erb                                                                                                  
#      format.xml  {   render :xml => @genomes }
      format.csv  {   render :csv => @buf }
    end
  end

  def new
    @genome = Genome.new
    @genome.public = true
  end
  
  def create
    @genome = Genome.new(params[:genome])
    @genome.frontend_session_id = session[:frontend_session_id]
    @genome.status_id = Status.find(:first, :conditions=>["name = ?", 'pending'])
    respond_to do |format|
      begin
        @genome.save &&
        Job.new(
                :runnable_type => "Genome",
                :runnable_id   => @genome.id,
                :running       => false
                ).save
        format.html        
      rescue Exception => e
        format.html {render :action => :new}
      end
    end
  end

  def update    
    @genome=Genome.find(params[:id])
    if params[:status_id] && params[:status_id] == '0'
      @genome.update_attribute(:status_id => 0)
    end    
  end

end
