require 'erb'

# load configurations from database.yml
database_yml_erb = File.read(File.join(File.dirname(__FILE__), 'database.yml'))
database_yml = ERB.new(database_yml_erb).result
ActiveRecord::Base.configurations = YAML.load(database_yml)

# set logfile
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

# load schema and fixtures to each db
ActiveRecord::Base.configurations.keys.each do |c|
  ActiveRecord::Base.establish_connection(c.to_sym)
  ActiveRecord::Migration.suppress_messages do
    load('schema.rb')
  end
  load('fixtures.rb')
end

ActiveRecord::Base.establish_connection(ENV['DB'] || :sqlite_db_0)

require "active_support"
require "database_rewinder"

# configure DatabaseRewinder
ActiveRecord::Base.configurations.keys.each do |c|
  DatabaseRewinder[c]
end