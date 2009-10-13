namespace :jbrowse do
  desc "Installs jbrowse code into JbrowseoR"
  task :install, [:version] do |t, args|
    codepath = Pathname.new(RAILS_ROOT) + "jbrowse"
    linkpath = Pathname.new(RAILS_ROOT) + "public" + "jbrowse"    

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

	$stderr.puts "Error building binaries for jbrowse"  unless system "make -C #{codepath}"
      end
    end
  end # task :install
end # namespace :jbrowse
