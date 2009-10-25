namespace :jbrowse do
  desc "Process genome fasta files in the queue"
  task :genomes, [:version] do |t, args|
 
    ### Use rails enviroment
    require "#{RAILS_ROOT}/config/environment" 
    
    ###Initialize variables
    jbrowse_data_dir = APP_CONFIG["jbrowse_data"]
    jbrowse_bin_dir = Pathname.new(RAILS_ROOT) + "jbrowse/bin/"
    puts "#{jbrowse_data_dir}"
    if  !File.exist?(jbrowse_data_dir)
      if jbrowse_data_dir != nil && jbrowse_data_dir != ''
        genome_data_dir = jbrowse_data_dir + "/genomes"
      else
        $stderr.puts "Jbrowse directory is not properly set in your config.yml"
      end
    end
    
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
      existing_genomes = Genome.find(:all, :conditions=>["status_id = ?", h_status['success']])
      if existing_genomes.size > 0
        puts "Existing genomes:\n" 
        + existing_genomes.map{|e| 
          "==>#{e.id}: #{e.name}; #{e.species}[#{e.tax_id}] -- " + 
          (e.public==true ? "PUBLIC" : "private[#{frontend_session_id}]")
        }.join("\n")
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

        ###writing file / computing size
        filename_new = genome_data_dir + "/#{g.id}_#{g.tax_id}.fa"
        File.open(filename_new, 'w') {|f| f.write(res) }
        file_size = File.size(filename_new)

        ###comparing public genome files / verifying uniqueness of file
        existing_genomes.reject{|e| e.public == false}.each do |e|
          filename_ex=genome_data_dir + "#{e.id}_#{e.tax_id}.fa"
          if (File.size(filename_ex)==file_size && 
              `diff #{filename_new} #{filename_ex}`.chomp == '')
            File.delete(filename_new)
            $stderr.puts "A public genome already exists on the server. You should find the existing genomes."
            break
          end
        end
        
        ###executing jbrowse script
        puts "==> Executing prepare-refseqs.pl...\n";
        system "#{jbrowse_bin_dir}/prepare-refseqs.pl --fasta #{filename_new}  --refs '#{g.chr_list}'"
        
      end ### end genome_lst.each
    end
  end
end    
