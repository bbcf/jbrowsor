require "csv"

class GenomesController < ApplicationController

  def index
    @genomes = Genome.find(:all, :conditions => ["public = ? and status_id = ?", true, 3])
    fields=['id', 'name','tax_id', 'species', 'url', 'chr_list', 'status_id', 'error_log', 'created_at', 'updated_at']
    
    @genomes_data=[]
    if params[:format] == 'yaml' || params[:format] == 'json'
      @genomes.each do |g|
        tmp_h = { }
        fields.map{ |f| tmp_h[f]=eval("g.#{f}")}
        @genomes_data.push(tmp_h)
      end
    end

    respond_to do |format|
      # format.html # index.html.erb
      # format.xml  {  render :xml => @genomes }
      format.csv  {  
        @buf = fields.join(',') + "\n"
        @genomes.each do |g|
          row=fields.map{|f| eval("g.#{f}.to_s")}
          CSV.generate_row(row, fields.size, @buf)
        end
        render :csv => @buf 
      }
      format.yaml {
        render :yaml => @genomes_data
      }
      format.json { 
        render :json => @genomes_data
      }
    end
  end

  def show
    @genome = Genome.find(params[:id])
    fields=['id', 'status_id','error_log'] 

    @h_genome = {}
    if params[:format] == 'yaml' || params[:format] == 'json'
      fields.map{ |f| @h_genome[f] = eval("@genome.#{f}")}
    end
    
    respond_to do |format|
      # format.html       
      # format.xml  {   render :xml => @genomes }
      format.csv  { 
        @buf = fields.join(',') + "\n"
        row=fields.map{|f| eval("@genome.#{f}.to_s")}
        CSV.generate_row(row, fields.size, @buf)
        render :csv => @buf 
      }
      format.yaml { 
        render :yaml => @h_genome 
      }
      format.json { 
        render :json => @h_genome
      }
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
