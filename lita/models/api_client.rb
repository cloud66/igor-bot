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

		def get_stack(stack_id)
			response = RegistrationManager.instance.access_token.get("#{API_URL}/stacks/#{stack_id}.json?show_log=true")
			stack_hash = JSON.parse(response.body)['response']
			return Stack.new(stack_hash)
		end

		def get_stack_services(stack_id)
			response = RegistrationManager.instance.access_token.get("#{API_URL}/stacks/#{stack_id}/services.json")
			services_hash = JSON.parse(response.body)['response']
			services = []
			services_hash.each do |service_hash|
				services << ::Service.new(service_hash)
			end
			return services.sort_by { |service| "#{service.name}" }
		end

		def deploy(id, services)
			url = "#{API_URL}/stacks/#{id}/deployments.json"
			query_string = services.map{|service| "services=#{CGI.escape(service)}"}.join('&')
			url = "#{url}?#{query_string}" unless query_string.empty?

			response = RegistrationManager.instance.access_token.post(url)
			hash = JSON.parse(response.body)['response']
			deploy_started = !hash['queued']
			return deploy_started
		end

	end
end