require 'fileutils'
#require 'console_app'
require 'config/environment'

namespace :jbrowse do
 task :uninstall, [:version] do |t, args|
    codepath = Pathname.new(RAILS_ROOT) + "jbrowse"
    linkpath = Pathname.new(RAILS_ROOT) + "public" + "jbrowse"

    FileUtils.remove_dir(codepath, true)
    FileUtils.remove_dir(linkpath, true)
  end
end
