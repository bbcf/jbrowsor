namespace :jbrowse do
  desc "Process jobs in the queue: first add new genomes, then add new tracks"
  task :jobs, [:version] do |t, args|
 
    ### Use rails enviroment
    require "#{RAILS_ROOT}/config/environment" 

    ### Require Net::HTTP
    require 'net/http'
    require 'uri'
    
    ###Initialize variables
    jbrowse_data_dir = APP_CONFIG["jbrowse_data"]
    jbrowse_bin_dir = Pathname.new(RAILS_ROOT) + "jbrowse/bin/"
    puts "APP_CONFIG\[jbrowse_data\] = #{jbrowse_data_dir}\n"
    if  !File.exist?(jbrowse_data_dir)
      if jbrowse_data_dir != nil && jbrowse_data_dir != ''
        genome_data_dir = jbrowse_data_dir + "/genomes"
      else
        $stderr.puts "Jbrowse directory is not properly set in your config.yml"
      end
    end

    ### get statuses 
    puts "Getting statuses...\n";
    h_status={}
    Status.find(:all).map{|s| h_status[s.name]=s.id}
    
    
    ######################## GENOMES
    
    ### get genome jobs to execute
    jobs = Job.find(:all, :conditions =>["running is false and runnable_type = ?", 'Genome'])
    num_jobs=jobs.size
    
    if jobs.size > 0 ### continue if there is something to do
      
      ### get existing genomes
      existing_genomes = Genome.find(:all, :conditions=>["status_id = ?", h_status['success']])
      if existing_genomes.size > 0
        puts "Existing genomes:\n" + (existing_genomes.map{|e| "==>#{e.id}: #{e.name}; #{e.species}-#{e.tax_id}-" + ((e.public==true) ? "PUBLIC" : "private-#{e.frontend_session_id}-")}.join(", "))
        
      else
        puts "No existing genomes yet.\n";
      end
      
      puts "#{num_jobs} new genome jobs...\n";
      
      ### foreach new genome
      jobs.each do |job|
        
        begin
          
          ###change running status of the job
          puts "==>Processing job #{job.id}...\n" 
          job.update_attribute(:running,  true)
          
          ###get the genome info
          g=Genome.find(job.runnable_id)
          
          ###get fasta file
          puts "==> Getting #{g.url}...\n"
          url = URI.parse(g.url)
          res = Net::HTTP.get(url)
          
          ###writing file / computing size
          puts "==> Writing file...\n"
          new_dir=jbrowse_data_dir + "/#{g.id}_#{g.tax_id}/"
          Dir.mkdir(new_dir) 
          filename_new = new_dir + "/_refseqs.fa"
          File.open(filename_new, 'w') {|f| f.write(res) }
          file_size = File.size(filename_new)
          
          ###comparing public genome files / verifying uniqueness of file
          puts "==> Comparing public genome files...\n"
          existing_genomes.reject{|e| e.public == false}.each do |e|
            filename_ex=jbrowse_data_dir + "/#{e.id}_#{e.tax_id}/_refseqs.fa"
            puts "--->Comparing with #{filename_ex}\n";
            puts "File.size(filename_ex) == file_size\n"
            puts "--" + `diff #{filename_new} #{filename_ex}`.chomp + "--\n"
            if (File.size(filename_ex)==file_size && 
                `diff #{filename_new} #{filename_ex}`.chomp == '')
              File.delete(filename_new)
              Dir.rmdir(new_dir)
              raise "A public genome already exists on the server. You should use the existing genomes_ID."
             # break
            end
          end
          
          ###executing jbrowse script
          puts "==> Executing prepare-refseqs.pl...\n";
          Dir.chdir(new_dir) do
            output = `#{jbrowse_bin_dir}/prepare-refseqs.pl --fasta _refseqs.fa  --refs '#{g.chr_list}'`                   
            raise "Error executing prepare-refseqs.pl: #{output}" unless (output == '')
          end
          
          g.update_attributes({:status_id => h_status['success']})
          
        rescue Exception => er
          $stderr.puts er.message
          g.update_attributes({:status_id => h_status['failure'], :error_log => er.message})
        end
        
        Job.find(job.id).destroy
        
      end ### end jobs.each
    end ### end if
    
    ##################################### TRACKS
    
    ### get track jobs to execute                                                                                                                          
    jobs = Job.find(:all, :conditions =>["running is false and runnable_type = ?", 'Track'])
    num_jobs=jobs.size
    
    if jobs.size > 0 ### continue if there is something to do                                                                                               
      ### get file types                                                                                                
      puts "Getting file types...\n";
      h_file_type={}
      FileType.find(:all).map{|ft| h_file_type[ft.id]=ft.name}

      ### get data types                                                                                              
      puts "Getting data types...\n";
      h_data_type={}
      DataType.find(:all).map{|dt| h_data_type[dt.id]=dt.name}


      puts "#{num_jobs} new track jobs...\n";
      
      ### foreach new track                                                                                                                                
      jobs.each do |job|
        
        begin
          
          ###change running status of the job           
          puts "==>Processing job #{job.id}...\n"
          job.update_attribute(:running,  true)
          
          ###get the track object                                                                   
          t=Track.find(job.runnable_id)
          g=Genome.find(t.genome_id)

          ###get wig/bed/gff file        
          puts "==> Getting #{t.url}...\n"
          url = URI.parse(t.url)
          res = Net::HTTP.get(url)
          
          ###writing file / computing size     
          genome_base_dir=jbrowse_data_dir + "/#{g.id}_#{g.tax_id}"
          filename="#{t.base_filename}_" + t.url.match(/([^\/]+)$/)[0]
          file_path=genome_base_dir + "/#{filename}"
          puts "==> Writing file #{file_path}...\n"
          File.open(file_path, 'w') {|f| f.write(res) }
     
          ### Change directory to work locally on the file
          Dir.chdir(genome_base_dir) do
            
            if  h_data_type[t.data_type_id] == 'qualitative'
              ### Qualitative track
              
              
            elsif h_data_type[t.data_type_id] == 'quantitative'
              ### Quantitative track
              
              wig_file=filename ## by default the original file
              
              if h_file_type[t.file_type_id] == 'wig'
                ### TO DO convert GFF -> WIG
                puts "Conversion GFF -> WIG...\n"
              elsif h_file_type[t.file_type_id] == 'bed'
                ### TO DO convert BED -> WIG
                puts "Conversion GFF -> WIG...\n"
              end
              
              ### assume we have a WIG file to process named wig_file
              ###executing jbrowse script                                                                                   
              puts "==> Executing wig2png...\n";              
              filename_without_extension=wig_file.match(/^(.+?)\.\w{3}/)[0]
              output = `#{jbrowse_bin_dir}/wig2png #{wig_file} ./data/tiles ./data/tracks #{filename_without_extension} #{t.jbrowse_params}`
              raise "Error executing wig2png: #{output}" unless (output == '')
             
            end
                        
          end
                    
          ### if arrives here, means that everything worked fine
          t.update_attributes({:status_id => h_status['success']})

          ### so let's delete the downloaded file -- if works fine move this line after the rescue
          File.delete(file_path)
          
        rescue Exception => er
          $stderr.puts er.message
          t.update_attributes({:status_id => h_status['failure'], :error_log => er.message})
        end

        ### delete file and delete job

        Job.find(job.id).destroy

      end ### each jobs.each
      
    end  ### end if
    
  end ### end task
end  ### end namespace  
