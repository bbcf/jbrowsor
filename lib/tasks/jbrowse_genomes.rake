namespace :jbrowse do
  desc "Process genome fasta files in the queue"
  task :genomes, [:version] do |t, args|
 
    ### Use rails enviroment
    require "#{RAILS_ROOT}/config/environment" 

    ### Require Net::HTTP
    require 'net/http'
    require 'uri'
    
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

    ######################## GENOMES
    
    genome_data_dir = jbrowse_data_dir + "/genomes"
    
    ### set genomes dir if not exist    
    puts "Setting genomes diretory...\n"
    Dir.mkdir genome_data_dir unless File.exist? genome_data_dir
    
    ### get statuses
    puts "Getting statuses...\n";
    h_status={}
    Status.find(:all).map{|s| h_status[s.name]=s.id}
    
    ### get genome jobs to execute
    jobs = Job.find(:all, :conditions =>["running is false and runnable_type = ?", 'Genome'])
    num_jobs=jobs.size
    
    if jobs.size > 0 ### continue if there is something to do
      
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
      
      puts "#{num_jobs} new jobs...\n";
      
      ### foreach new genome
      jobs.each do |job|
        
        begin
          
          ###change running status of the job
          puts "==>Processing job #{job.id}...\n" 
          job.update_attribute(:running,  true)
          
          ###get the genome info
          g=Genome.find(job.runnable_id)
          
          ###get fasta file
          puts "==> Getting #{g.url}...\n";
          url = URI.parse(g.url)
          res = Net::HTTP.get(url)
          
          ###writing file / computing size
          new_dir=genome_data_dir + "/#{g.id}_#{g.tax_id}"
          Dir.mkdir(new_dir) 
          filename_new = new_dir + "/_refseqs.fa"
          File.open(filename_new, 'w') {|f| f.write(res) }
          file_size = File.size(filename_new)
          
          ###comparing public genome files / verifying uniqueness of file
          existing_genomes.reject{|e| e.public == false}.each do |e|
            filename_ex=genome_data_dir + "/#{e.id}_#{e.tax_id}/_refseqs.fa"
            if (File.size(filename_ex)==file_size && 
                `diff #{filename_new} #{filename_ex}`.chomp == '')
              File.delete(filename_new)
              Dir.rmdir(new_dir)
              $stderr.puts "A public genome already exists on the server. You should find the existing genomes."
              break
            end
          end
          
          ###executing jbrowse script
          puts "==> Executing prepare-refseqs.pl...\n";
          Dir.chdir(new_dir) do
            output = `#{jbrowse_bin_dir}/prepare-refseqs.pl --fasta _refseqs.fa  --refs '#{g.chr_list}'`                   
            raise "Error executing prepare-refseqs.pl: #{output}" unless (output == '')
          end
          
        rescue Exception => er
          g.update_attributes({:status_id => h_status['failure'], :error_log => er.message})
        end
        
        Job.find(job.id).destroy
        
      end ### end genome_lst.each
    end

    ##################################### TRACKS
    
    

  end
end    
