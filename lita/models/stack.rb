require 'httparty'

class Stack
	attr_accessor :name,
				  :last_activity,
				  :environment,
				  :framework,
				  :id,
				  :status,
				  :cloud

	def initialize(stack_hash)
		@name = stack_hash['name']
		@last_activity = DateTime.parse(stack_hash['last_activity']) rescue nil
		@environment = stack_hash['environment']
		@framework = stack_hash['framework']
		@id = stack_hash['uid']
		@status = parse_status(stack_hash)
		@cloud = stack_hash['cloud']
	end

	def last_activity_text
		@last_activity.nil? ? 'none' : @last_activity.strftime('%Y-%m-%d %H:%M:%S')
	end

	def active?
		return @status == :active
	end

	def custom_active?
		custom_activity_url = ConfigManager.instance.get_custom_activity_url(@name, @environment)
		return false if custom_activity_url.nil?

		http_resp = HTTParty.get(custom_activity_url) rescue nil
		if http_resp.nil? || http_resp.code != 200
			raise "Failed HTTP GET request to custom-activity-url for #{@name} [#{@environment}] (\"#{custom_activity_url}\")"
		else
			params = http_resp.parsed_response
			payload = params['response'] || params
			keys = %w(is_currently_active is_busy busy is_active active is_working)
			value = nil
			keys.each { |k| value = payload[k] unless payload[k].nil? }
			raise "Unknown return value from request to custom-activity-url for #{@name} [#{@environment}] (\"#{custom_activity_url}\")" if value.nil?
			return value.to_bool
		end
	end

	def notify_color
		if self.active?
			return Colors::BLUE
		elsif @status == :error
			return Colors::RED
		elsif @status == :unrecoverable
			return Colors::BLACK
		elsif @status == :impaired
			return Colors::ORANGE
		else
			return Colors::GREEN
		end
	end

	private

	def parse_status(stack_hash)
		return :active if [0, 3, 5, 6].include?(stack_hash['status'])
		return :error if [2].include?(stack_hash['status'])
		return :unrecoverable if [7].include?(stack_hash['status'])
		return :error if [4].include?(stack_hash['health'])
		return :active if [1].include?(stack_hash['health'])
		return :impaired if [2].include?(stack_hash['health'])
		return :good
	end
end
