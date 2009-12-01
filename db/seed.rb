require 'active_record/fixtures'

directory = Rails.root + "db" + "seed_data"
Dir::entries(directory).select{|e| e =~ /\.yml$/}.each do |filename|
  Fixtures.create_fixtures(directory, File.basename(filename, ".yml"))
  $stderr.puts File.basename(filename, ".yml")
end
