APP_ROOT_PATH = File.expand_path(File.dirname(__FILE__))
require 'fileutils'
require 'json'
Dir['lita/lib/*.rb'].each { |file| require_relative file }
Dir['lita/models/*.rb'].each { |file| require_relative file }
Dir['lita/handlers/abstract_*.rb'].each { |file| require_relative file }
Dir['lita/handlers/*.rb'].each { |file| require_relative file }
Lita.configure do |config|
	config.robot.log_level = (ENV.fetch('LITA_INFO_LEVEL') { :warn }).to_sym
	config.redis[:host] = ENV['REDIS_HOST'] || ENV['REDIS_ADDRESS'] || 'localhost'
	config.redis[:port] = ENV['REDIS_PORT'] || 6379
	config.robot.adapter = :slack
  if(config.adapters.respond_to?(:slack))
    slack_token_json = JSON.parse((File.read("/opt/chat-ops-common/slack-token.json")))
    config.adapters.slack.token = slack_token_json["slack_token"]
  end
end