Dir.glob('tasks/*.rake').each { |r| import r }
$LOAD_PATH << File.expand_path('../lib/fixture', __FILE__)
$LOAD_PATH << File.expand_path('../lib/factory', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)
$LOAD_PATH << File.expand_path('../', __FILE__)
Dir.glob('models/*.rb').each { |m| require m }
require 'fixturer'

task :default do
  puts DBconnect.instance.query("SELECT MAX(id) FROM #{Test}s").values.flatten[0].to_i + 1
end