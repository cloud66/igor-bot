require 'singleton'

class ConfigManager
	include ::Singleton

	CONFIG_LOCATION = "#{APP_ROOT_PATH}/config/config.yml"

	def initialize
		@custom_activity_urls = {}
		if File.exists?(CONFIG_LOCATION)
			config_hash = YamlHelper.safe_load_file(CONFIG_LOCATION) rescue {}
			stack_defs = config_hash['stacks'] || []
			stack_defs.each do |stack_def|
				key = get_unique_key(stack_def['name'], stack_def['environment'])
				@custom_activity_urls[key] = stack_def['custom_activity_url']
			end
		end
	end

	def get_custom_activity_url(stack, environment)
		key = get_unique_key(stack, environment)
		return @custom_activity_urls[key]
	end

	private

	def get_unique_key(stack, environment)
		return "#{stack}|#{environment}".downcase
	end

end
