$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'main'
$LOAD_PATH << File.expand_path('../../', __FILE__)
Dir.glob('models/*.rb').each { |m| require m }
