require 'lita/rspec'
require './lita_config.rb'
require './lita/handlers/abstract_handler'
require 'oauth2'
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__FILE__), 'mocks', '*.rb')].each { |file| require file }
Lita.version_3_compatibility_mode = false

RSpec.configure do |config|

end


