APP_ROOT_PATH = File.expand_path(File.dirname(__FILE__))

Dir['lita/lib/*.rb'].each { |file| require_relative file }
Dir['lita/models/*.rb'].each { |file| require_relative file }
Dir['lita/handlers/*.rb'].each { |file| require_relative file }
Lita.configure do |config|
	config.robot.log_level = (ENV.fetch('LITA_INFO_LEVEL') { :warn }).to_sym
	config.redis[:host] = ENV['REDIS_HOST'] || ENV['REDIS_ADDRESS'] || 'localhost'
	config.redis[:port] = ENV['REDIS_PORT'] || 6379
	config.robot.adapter = :slack
	config.adapters.slack.token = ENV['SLACK_TOKEN']
end

