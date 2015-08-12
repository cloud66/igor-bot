Dir['lita/handlers/*.rb'].each { |file| require_relative file }

Lita.configure do |config|
	config.robot.log_level = ENV['LITA_INFO_LEVEL'].to_sym
	config.redis[:host] = ENV['REDIS_HOST']
	config.redis[:port] = ENV['REDIS_PORT']
	config.robot.adapter = :slack
	config.adapters.slack.token = ENV['SLACK_TOKEN']
	# config.handlers.clapper.command_only = true
end

