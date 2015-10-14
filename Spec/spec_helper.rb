$LOAD_PATH << File.expand_path('../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../lib/fixture', __FILE__)
$LOAD_PATH << File.expand_path('../../lib/factory', __FILE__)
$LOAD_PATH << File.expand_path('../../models', __FILE__)

require 'dbconnect'
require 'fixturer'

RSpec.configure do |config|
	config.expect_with(:rspec) {|c| c.syntax = :should }
end