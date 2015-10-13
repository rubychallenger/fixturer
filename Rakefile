Dir.glob('tasks/*.rake').each { |r| import r }
$LOAD_PATH << File.expand_path('../lib/fixture', __FILE__)
$LOAD_PATH << File.expand_path('../lib/factory', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'fixturer'

task :default do
  puts AbstractFactory::JsonFactory.instance_methods.sort
  puts fixture
  puts factory
end