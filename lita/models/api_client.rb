require 'singleton'
require 'json'

module Models
	class ApiClient
		API_URL = 'https://app.cloud66.com/api/3'

		def get_stacks(stack_name: nil, environment: nil)
			response = RegistrationManager.instance.access_token.get("#{API_URL}/stacks.json")
			stacks_hash = JSON.parse(response.body)['response']
			stacks = []
			stacks_hash.each do |stack_hash|
				# skip if we've specified stack as an option
				next if stack_name && !stack_hash['name'].downcase.include?(stack_name.downcase)
				next if environment && !stack_hash['environment'].downcase.include?(environment.downcase)
				stacks << Stack.new(stack_hash)
			end
			return stacks.sort_by { |stack| "#{stack.name.downcase}|#{stack.environment}" }
		end

		def get_stack(id)
			response = RegistrationManager.instance.access_token.get("#{API_URL}/stack/#{id}.json")
			stack_hash = JSON.parse(response.body)['response']
			return Stack.new(stack_hash)
		end

		def deploy(id, service_names = [])
			# response = RegistrationManager.instance.access_token.post("#{API_URL}/stack/#{id}.json")
			# stack_hash = JSON.parse(response.body)['response']
			# return Stack.new(stack_hash)
		end

	end
end