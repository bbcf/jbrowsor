namespace :jbrowse do
  desc "Process genome fasta files in the queue"
  task :genomes, [:version] do |t, args|
 
    ### Use rails enviroment
    require "#{RAILS_ROOT}/config/environment" 
    
    ###Initialize variables
    jbrowse_data_dir = APP_CONFIG["jbrowse_data"]
    puts "#{jbrowse_data_dir}"
    Dir.mkdir(jbrowse_data_dir) if (jbrowse_data_dir != nil && jbrowse_data_dir != '' && !File.exist?(jbrowse_data_dir)) 
    genome_data_dir = jbrowse_data_dir + "/genomes"
    
    ### set genomes dir if not exist    
    puts "Setting genomes diretory...\n"
    Dir.mkdir genome_data_dir unless File.exist? genome_data_dir

    ### get statuses
    puts "Getting statuses...\n";
    h_status={}
    Status.find(:all).map{|s| h_status[s.name]=s.id}

    ### get genomes to compute
    genome_lst = Genome.find(:all, :conditions => ["status_id = ?", h_status['pending']])
    num_new_genomes=genome_lst.size

    if genome_lst.size > 0 ### continue if there is something to do
      
      ### get existing genomes
      existing_genomes = Dir.entries(genome_data_dir).reject{|e| e.match(/^\./)}
      if existing_genomes.size > 0
        puts "Existing genomes:\n" + existing_genomes.map{|e| "==>#{e}"}.join("\n")
      else
        puts "No existing genomes yet.\n";
      end

      
      puts "#{num_new_genomes} new genomes to treat...\n";

      ### foreach new genome
      genome_lst.each do |g|
        
        ###get fasta file
        puts "==> Getting #{g.url}...\n";
        require 'net/http'
        require 'uri'        
        url = URI.parse(g.url)
        res = Net::HTTP.get(url)

        ###writing file
        File.open(genome_data_dir + "/#{g.id}.fa", 'w') {|f| f.write(res) }

        

      end ### end genome_lst.each
    end
  end
end    
