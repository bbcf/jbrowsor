class GenomesController < ApplicationController

  def index
    @genomes = Genome.find(:all)
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
