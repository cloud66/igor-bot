require 'singleton'
require 'json'

module Models
	class ApiClient
		API_URL = 'https://stage.cloud66.com/api/3'

		def get_stacks(stack_name: nil, environment: nil)
			stacks_hash = get_stacks_from_api
			stacks = []
			stacks_hash.each do |stack_hash|
				# skip if we've specified stack as an option
				next if stack_name && !stack_hash['name'].downcase.include?(stack_name.downcase)
				next if environment && !stack_hash['environment'].downcase.include?(environment.downcase)
				stacks << Stack.new(stack_hash)
			end
			return stacks.sort_by { |stack| "#{stack.name.downcase}|#{stack.environment}" }
		end

		def get_stacks_from_api
			response = RegistrationManager.new.access_token.get("#{API_URL}/stacks.json")
			return JSON.parse(response.body)['response']
		end

		def get_stack(stack_id)
			stack_hash = get_stack_from_api(stack_id)
			return Stack.new(stack_hash)
		end

		def get_stack_from_api(stack_id)
			response = RegistrationManager.new.access_token.get("#{API_URL}/stacks/#{stack_id}.json?show_log=true")
			return JSON.parse(response.body)['response']
		end

		def get_stack_services(stack_id)
			services_hash = get_stack_services_from_api(stack_id)
			services = []
			services_hash.each do |service_hash|
				services << ::Service.new(service_hash)
			end
			return services.sort_by { |service| "#{service.name}" }
		end

		def get_stack_services_from_api(stack_id)
			response = RegistrationManager.new.access_token.get("#{API_URL}/stacks/#{stack_id}/services.json")
			return JSON.parse(response.body)['response']
		end

		def deploy(id, services)
			hash = deploy_from_api(id, services)
			deploy_started = !hash['queued']
			return deploy_started
		end

		def deploy_from_api(id, services)
			url = "#{API_URL}/stacks/#{id}/deployments.json"
			# query_string = services.map { |service| "services=#{CGI.escape(service)}" }.join('&')
			# url = "#{url}?#{query_string}" unless query_string.empty?
			response = RegistrationManager.new.access_token.post(url, { body: { services: services } })
			return JSON.parse(response.body)['response']
		end

		def set_stack_for_test(stack)
			#Do nothing, only here to be redefine by the tests, do not delete
		end
	end
end
