$LOAD_PATH << File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../lib/fixture', __FILE__)
$LOAD_PATH << File.expand_path('../../lib/factory', __FILE__)
$LOAD_PATH << File.expand_path('../../', __FILE__)
Dir.glob('models/*.rb').each { |m| require m }
require 'dbconnect'
require 'fixturer'
