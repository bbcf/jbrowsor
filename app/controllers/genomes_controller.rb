require "csv"

class GenomesController < ApplicationController

  def index
    @genomes = Genome.find(:all, :conditions => ["public = ?", true])
    fields=['id', 'name','tax_id', 'species', 'url', 'chr_list', 'status_id', 'error_log', 'created_at', 'updated_at']
    
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
        render :yaml => @genomes
      }
    end
  end

  def show
    @genome = Genome.find(params[:id])
    fields=['id', 'status_id','error_log'] 
  
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
        @genome_selection = {  }
        fields.map{ |f| @genome_selection[f] = eval("@genome.#{f}")}
        render :yaml => @genome_selection 
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
