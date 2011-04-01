require 'console_app'
require 'config/environment'
require 'fileutils'
require 'yaml'

namespace :jbrowse do
  desc "Installs jbrowse code into JbrowseoR"
  task :install, [:version] do |t, args|

    ### Use rails enviroment                                                                                                          
    require "#{RAILS_ROOT}/config/environment"

    jbrowse_git_branch = "gdv" #switch back to  "master" eventually ?
    jbrowse_git_repo = "git://github.com/bbcf/jbrowse"

    jbrowse_data_dir = Pathname.new APP_CONFIG["jbrowse_data"]
    jbrowse_views_dir = Pathname.new APP_CONFIG["jbrowse_views"]

    gdv_git_branch = "dev"
    gdv_git_repo = "git://github.com/bbcf/gdv.git"

    tmpdir = Pathname.new "/tmp"

    codepath = Pathname.new(RAILS_ROOT) + "jbrowse"
    linkpath = Pathname.new(RAILS_ROOT) + "public" + "jbrowse"

    compute_conf_hash = {
      "tmp_directory" => tmpdir.to_s,
      "feedback_url"=>app.url_for(:controller => :tracks, :action => :gdv_conversion_done)
    }

    transform_conf_hash = {
      "sqlite_output_directory" => "",
      "jbrowse_output_directory" => "",
      "compute_sqlite_scores_database" => "",
      "feedback_url" => "",
      "database_link" => "",
      "jbrowse_ressource_url" => ""
    }

    os = `uname`.chomp
    $stderr.puts "Running under #{os}."

    if File.exist? codepath or File.exist? linkpath
      $stderr.puts "jbrowse directory already exists, aborting installation!"
    else
      $stderr.puts "Version not implemented yet, sorry" if args[:version]
      system "git clone -b #{jbrowse_git_branch} #{jbrowse_git_repo} #{codepath}"

      unless File.exist? codepath + "css" + "genome.css" and File.exist? codepath + "js" and File.directory? codepath + "js" and File.exist? codepath + "jslib" and File.directory? codepath + "jslib"
	$stderr.puts "jbrowse code structure appears to have changed, unable to complete installation"
      else
	Dir.mkdir linkpath

	File.symlink(codepath + "css", linkpath + "css")
	File.symlink(codepath + "js", linkpath + "js")
	File.symlink(codepath + "jslib", linkpath + "jslib")
       File.symlink(codepath + "img", linkpath + "img")
       File.symlink(jbrowse_data_dir, linkpath + "data")
       File.symlink(jbrowse_views_dir, linkpath + "views")

        # modify query url in js file
        File.rename(codepath + "js" + "gdv_canvas.js", (codepath + "js" + "gdv_canvas.js_bak"))
        File.open(codepath + "js" + "gdv_canvas.js", 'w') do |outfile|
          File.open(codepath + "js" + "gdv_canvas.js_bak") do |infile|
           infile.each_line do |line|
              line.sub!(/var _POST_URL = \"[^\"]+\"/, "var _POST_URL = #{app.url_for(:controller => :tracks, :action => :gdv_query)}") 
              outfile.puts line
            end
          end
        end

	p "make -C #{codepath}"

        if os == "Darwin" 
          gcc_lib_args = ["/opt/local/lib", "/usr/X11/lib"]
	  gcc_inc_args = ["/opt/local/include", "/usr/X11/include"]
          cmd = "make  GCC_LIB_ARGS='" + gcc_lib_args.map{ |e| "-L#{ e}"}.join(' ') + "' GCC_INC_ARGS='" + gcc_inc_args.map{|e| "-I#{e}"}.join(' ') + "' -C #{codepath}"
	  $stderr.puts cmd + "\n"
          $stderr.puts "Error building binaries for jbrowse" unless system cmd
        else
          $stderr.puts "Error building binaries for jbrowse" unless system "make -C #{codepath}"
        end

        cd tmpdir do
          system "git clone -b #{gdv_git_branch} #{gdv_git_repo} gdv"
          FileUtils.mkdir(codepath + "conversion")

          cd "gdv/conversion/compute_sqlite_scores" do
            $stderr.puts "Error building binaries - compute_sqlite_scores" unless system 'ant jar'
          end
          FileUtils.mkdir_p(codepath + "conversion" + "compute_to_sqlite" + "conf")
          FileUtils.cp(tmpdir + "gdv" + "conversion" + "compute_sqlite_scores" + "compute_to_sqlite.jar",  codepath + "conversion" + "compute_to_sqlite")
          FileUtils.cp_r(tmpdir + "gdv" + "conversion" + "compute_sqlite_scores" + "lib",  codepath + "conversion" + "compute_to_sqlite" + "lib")
          File.open(codepath + "conversion" + "compute_to_sqlite" + "conf" + "conf.yaml", 'w'){|out| out.puts(compute_conf_hash.to_yaml)}

          cd "gdv/conversion/transform_to_sqlite" do
            $stderr.puts "Error building binaries - transform_to_sqlite" unless system 'ant jar'
          end
          FileUtils.mkdir_p(codepath + "conversion" + "transform_to_sqlite" + "conf")
          FileUtils.cp(tmpdir + "gdv" + "conversion" + "transform_to_sqlite" + "transform_to_sqlite.jar",  codepath + "conversion" + "transform_to_sqlite")
          FileUtils.cp_r(tmpdir + "gdv" + "conversion" + "transform_to_sqlite" + "lib",  codepath + "conversion" + "transform_to_sqlite" + "lib")
          File.open(codepath + "conversion" + "transform_to_sqlite" + "conf" + "conf.yaml", 'w'){|out| out.puts(transform_conf_hash.to_yaml)}
        end
        FileUtils.remove_dir(tmpdir + "gdv", true)
        
      end
    end
  end # task :install
end # namespace :jbrowse
