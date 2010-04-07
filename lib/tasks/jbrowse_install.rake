namespace :jbrowse do
  desc "Installs jbrowse code into JbrowseoR"
  task :install, [:version] do |t, args|

    ### Use rails enviroment                                                                                                          
    require "#{RAILS_ROOT}/config/environment"
    
    jbrowse_data_dir = APP_CONFIG["jbrowse_data"]

    codepath = Pathname.new(RAILS_ROOT) + "jbrowse"
    linkpath = Pathname.new(RAILS_ROOT) + "public" + "jbrowse"
    os = `uname`.chomp
    puts "Running under #{os}."

    if File.exist? codepath or File.exist? linkpath
      $stderr.puts "jbrowse directory already exists, aborting installation!"
    else
      $stderr.puts "Version not implemented yet, sorry" if args[:version]
      system "git clone git://github.com/jbrowse/jbrowse.git #{codepath}"

      unless File.exist? codepath + "genome.css" and File.exist? codepath + "js" and File.directory? codepath + "js" and File.exist? codepath + "jslib" and File.directory? codepath + "jslib"
	$stderr.puts "jbrowse code structure appears to have changed, unable to complete installation"
      else
	Dir.mkdir linkpath

	File.symlink(codepath + "genome.css", linkpath + "genome.css")
	File.symlink(codepath + "js", linkpath + "js")
	File.symlink(codepath + "jslib", linkpath + "jslib")
        File.symlink(jbrowse_data_dir, linkpath + "data")
        
	p "make -C #{codepath}"

        if os == "Darwin" 
          gcc_lib_args = ["/opt/local/lib", "/usr/X11/lib"]
	  gcc_inc_args = ["/opt/local/include", "/usr/X11/include"]
          cmd = "make  GCC_LIB_ARGS='" + gcc_lib_args.map{ |e| "-L#{ e}"}.join(' ') + "' GCC_INC_ARGS='" + gcc_inc_args.map{|e| "-I#{e}"}.join(' ') + "' -C #{codepath}"
	  puts cmd + "\n"
          $stderr.puts "Error building binaries for jbrowse" unless system cmd
        else
          $stderr.puts "Error building binaries for jbrowse" unless system "make -C #{codepath}"
        end
      end
    end
  end # task :install
end # namespace :jbrowse
