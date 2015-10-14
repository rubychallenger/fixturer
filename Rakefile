Dir.glob('tasks/*.rake').each { |r| import r }
$LOAD_PATH << File.expand_path('../lib/fixture', __FILE__)
$LOAD_PATH << File.expand_path('../lib/factory', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)
$LOAD_PATH << File.expand_path('../models/*', __FILE__)

require 'fixturer'

task :default do
  con = DBconnect.instance()

  puts Posts.where("id = ? AND name = ?",100,"Vadym").name

  puts Posts.where("id = ? AND name = ?",100,"sdym").name
end