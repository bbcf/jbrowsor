#! /usr/bin/env ruby
# -*- coding: iso-8859-1 -*-
require 'daemons'
require 'pathname'
require 'fileutils'
require 'sqlite3'

### Generate absolute path of environment.rb
env_file = Pathname.new(__FILE__).realpath.parent.parent.parent + "config" + "environment.rb"

unless File.exist?(env_file)
  $stderr.puts "Cannot find \"environment.rb\""
  abort
end

Daemons.run_proc('job_runner.rb') do
  sleep_duration = 12
  $stderr.puts "in Daemons.run_proc"

  ### Require environment (using absolute path since daemon runs in root directory)
  require(env_file)

  ### Require Net::HTTP
  require 'net/http'
  require 'uri'

  ### Json parsing
  require 'ftools'

  ###Initialize variables
  jbrowse_data_dir = Pathname.new(APP_CONFIG["jbrowse_data"])
  jbrowse_bin_dir = Pathname.new(RAILS_ROOT) + "jbrowse" + "bin"
  compute_to_sqlite_jobs_db = Pathname.new(RAILS_ROOT) + "jbrowse" + "conversion" + "compute_to_sqlite" + "jobs.db"
  transform_to_sqlite_jobs_db = Pathname.new(RAILS_ROOT) + "jbrowse" + "conversion" + "transform_to_sqlite" + "jobs.db"

  $stderr.puts "compute_to_sqlite_jobs_db: #{compute_to_sqlite_jobs_db.to_s}"

  raise "Jbrowse data directory is not properly set in your config.yml" if jbrowse_data_dir.nil? or jbrowse_data_dir.to_s.empty?
  raise "The Jbrowse data directory is set as #{jbrowse_data_dir}, but this file is not a directory" if File.exist?(jbrowse_data_dir) and not File.directory?(jbrowse_data_dir)
  Dir.mkdir jbrowse_data_dir unless File.exist?(jbrowse_data_dir)

  $stderr.puts "environment: #{RAILS_ENV}"
  $stderr.puts "data_dir:   #{jbrowse_data_dir}"

  ### get statuses 
  puts "Getting statuses...\n";
  h_status={}
  Status.find(:all).each{|s| h_status[s.name]=s.id}

  stalejobs = Job.find(:all, :conditions =>["running is true"], :order => "updated_at")
  if stalejobs.size > 0
    $stderr.puts "Resetting stale jobs (ids: #{stalejobs.map{|j| j.id}.join(", ")})"
    stalejobs.each do |j|
      j.update_attribute(:running, false)
      # TODO Job cleanup for stale/interrupted jobs -> remove temporary files etc
      case j.runnable
      when Genome
	
      when Track
	
      end
    end
  end

  loop do
    $stderr.puts "loop"
    job = nil

    ## Select next job and set it to running
    Job.transaction do
      job = Job.first(:conditions =>["running is false"], :order => "updated_at")
      if job
        job.update_attribute(:running,  true)
        job.runnable.update_attribute(:status_id, h_status['running'])
      end
    end

    unless job.nil?
      case job.runnable
      when Genome
	#################### GENOMES
	$stderr.puts "Job is a genome job"
	begin
          
	  puts "==>Processing job #{job.id}..." 

	  ###get the genome info
	  g=job.runnable

	  g_dir=jbrowse_data_dir + "#{g.id}"
	  g_filename = g_dir + "_refseqs.fa"

	  	  ###get fasta file
	  #	  puts "==> Getting #{g.url}..."
	  #	  url = URI.parse(g.url)
	  #	  # res = Net::HTTP.get(url)
	  #	  Net::HTTP.start(url.host) do |http|
	  #	    http.request_get(url.path) do |response|
	  #	      puts "==> Creating directory..."
	  #	      Dir.mkdir(g_dir) 
	  #	      puts "==> Writing file..."
	  #	      File.open(g_filename, 'w') do |f|
	  #		response.read_body do |segment|
	  #		  f.write(segment)
	  #		end # |segment|
	  #	      end # |f|
	  #	    end # |response|
	 #	  end # |http|

	  # For debugging without downloading
	  url = URI.parse(g.url)
	  Dir.mkdir(g_dir)
	  File.copy(jbrowse_data_dir + "chromFa.tar.gz", g_filename, true)
	  # end For debugging without downloading

	  ###uncompressing/concatenating/computing size
	  case url.path
	  when /(tar.gz|tgz)$/
	    tmp_extraction_dir = g_dir + "tmp_extraction"
	    Dir.mkdir(tmp_extraction_dir)
	    puts  "tar -C #{tmp_extraction_dir} -zxvf #{g_filename}"
	    if system "tar -C #{tmp_extraction_dir} -zxvf #{g_filename}"
	      puts "untared"
	      File.delete(g_filename)
	      system "cat #{tmp_extraction_dir + "*"} > #{g_filename}"
	      puts "cat done"
	      puts Dir.entries(tmp_extraction_dir).inspect
	      Dir.foreach(tmp_extraction_dir){|f| File.delete tmp_extraction_dir + f unless File.directory?(tmp_extraction_dir + f)}
	      Dir.rmdir tmp_extraction_dir
	    else
	      raise "unable to extract tar file"
	    end
	  when /(\.gz|\.Z)/
	    # TODO Implement extraction of *.gz and *.Z -> Fabrice
	  end

	  ###executing jbrowse script
	  puts "==> Executing prepare-refseqs.pl...\n";
	  Dir.chdir(g_dir) do
	    output = `#{jbrowse_bin_dir}/prepare-refseqs.pl --fasta _refseqs.fa  --refs '#{g.chr_list}'`                   
	    raise "Error executing prepare-refseqs.pl: #{output}" unless (output == '')
	  end

	  ###comparing public genome files / verifying uniqueness of file
	  puts "==> Comparing public genome files..."
	  Genome.find(:all, :conditions=>["status_id = ?", h_status['success']]).reject{|e| e.hidden == true or e.status.name != "success"}.each do |e|
	    e_dir = jbrowse_data_dir + "#{e.id}"

	    puts "--->Comparing with #{e.name}";
	    puts "--" + `diff #{g_dir + "data" + "trackInfo.js"} #{e_dir + "data" + "trackInfo.js"}`.chomp + "--"
	    if ( `diff #{g_dir + "data" + "trackInfo.js"} #{e_dir + "data" + "trackInfo.js"}`.chomp.empty?)
	      different = false
	      time = DateTime.now
	      IO.popen("diff -r -q #{g_dir + "data" + "seq"} #{e_dir + "data" + "seq"}") do |pipe|
		pipe.each_line do |l|
		  unless l.empty?
		    different = true
		    break
		  end
		end
		Process.kill 'TERM', pipe.pid
	      end
	      puts "Diff took: " + (DateTime.now - time).to_f.to_s
	      unless different
		require 'fileutils'
		FileUtils.rm_rf(g_dir)
		raise "A public genome already exists on the server. You should use the existing genome_ID #{e.id}."
	      end
	    end
	  end

	  g.update_attributes({:status_id => h_status['success']})
	  
	rescue Exception => er
	  $stderr.puts er.message
	  g.update_attributes({:status_id => h_status['failure'], :error_log => er.message})
	end

	File.delete(g_filename) if File.exist? g_filename
	Job.find(job.id).destroy

      when Track
	#################### TRACKS
	$stderr.puts "Job is a track job"
	begin
	  $stderr.puts "==>Processing job #{job.id}..." 

	  ###get the genome info
	  t=job.runnable
	  g=t.genome
	  genome_base_dir = jbrowse_data_dir + "#{g.id}"
	  feature_file = "#{t.base_filename}.#{t.file_type.name}"
          track_data_path = jbrowse_data_dir + t.genome_id.to_s + "data" + "tracks"
	  config_file = genome_base_dir + "#{t.base_filename}_conf.json"

	  ###get wig/bed/gff/sql file
          $stderr.puts "==> Getting track information #{t.url}...\n"
          url = URI.parse(t.url)
	  Net::HTTP.start(url.host) do |http|
	    http.request_get(url.path) do |response|
	      File.open(genome_base_dir + feature_file, 'w') do |f|
		response.read_body do |segment|
		  f.write(segment)
		end # |segment|
	      end # |f|
	    end # |response|
	  end # |http|

          $stderr.puts "File type: " + t.file_type.name
          if t.file_type.name == "sql"
            if t.data_type.name == "qualitative"
              raise "Qualitative data tracks from sql not yet implemented"
              #TODO fix/remove once we have qualitative sql conversion sorted out
            end 

            FileUtils.mkdir_p(track_data_path.to_s)
            SQLite3::Database.open(compute_to_sqlite_jobs_db.to_s) do |db|
              $stderr.puts db.database_list
              $stderr.puts "I"
              db.execute("INSERT INTO jobs(trackId,indb,inpath,outdb,outpath,rapidity,mail) VALUES (:trackId,:indb,:inpath,:outdb,:outpath,:rapidity,:mail)", 
                         :trackId => t.id,
                         :indb => "#{t.base_filename}.#{t.file_type.name}",
                         :inpath => genome_base_dir.to_s,
                         :outdb => t.base_filename,
                         :outpath => track_data_path.to_s,
                         :rapidity => 1,
                         :mail => ""
                         )
            end
            $stderr.puts "II"
            Job.find(job.id).destroy

          else


          end

#	  Dir.chdir(genome_base_dir) do
#	    ###### Write the config file 
#	    case t.data_type.name
#	    when "qualitative"
#	      if t.file_type.name == "bed"
#		# todo convert to gff
#
#	      end
#	      ###### Write the config file 
#              puts "Write config file...\n"
#              f_conf_file = File.new("conf_file.json", 'w') or raise "Cannot open file conf_file.json!"
#              conf_data = ActiveSupport::JSON.decode(t.jbrowse_params)
#	      conf_data['tracks'][0]['track'] = t.base_filename
#              conf_data['description']="Database Test"
#              conf_data['db_adaptor']="Bio::DB::SeqFeature::Store"
#              conf_data['db_args']={
#                "-adaptor" => "memory",
#                "-dir"     => "annot_gff" ### write gff data into this directory
#              } 
#              f_conf_file.write(conf_data.to_json)
#              f_conf_file.close
#
#	    when "quantitative"
#	      ###### Execute biodb-to-json.pl
#              puts "==> Executing biodb-to-json.pl...\n";
#              output = `#{jbrowse_bin_dir}/biodb-to-json.pl --conf conf_file.json 1>biodb-to-json.log 2>biodb-to-json.error_log`
#	      
#	    end
#
#	  end # chdir

	rescue Exception => er
	  $stderr.puts er.message
	  t.update_attributes({:status_id => h_status['failure'], :error_log => er.message})
	end

      else # not valid runnable
	$stderr.puts "ERROR: Invalud job type"
      end
    end
    $stderr.puts "going to sleep"
    sleep(sleep_duration)
  end
end
