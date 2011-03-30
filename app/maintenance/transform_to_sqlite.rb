#! /usr/bin/env ruby
# -*- coding: iso-8859-1 -*-
require 'daemons'
require 'pathname'
require 'fileutils'

### Generate absolute path of environment.rb
env_file = Pathname.new(__FILE__).realpath.parent.parent.parent + "config" + "environment.rb"

unless File.exist?(env_file)
  $stderr.puts "Cannot find \"environment.rb\""
  abort
end
require(env_file)


Daemons.run_proc("transform_to_sqlite") do
  FileUtils::cd(Pathname.new(RAILS_ROOT) + "jbrowse" + "conversion" + "transform_to_sqlite") do
    exec("java -jar transform_to_sqlite.jar")
  end
end
