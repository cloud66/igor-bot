require 'httparty'

module Lita
	module Handlers
		class Deployer < AbstractHandler

			WAIT_CHECK_FREQ = 30 # 30 seconds
			WAIT_TIMEOUT = 60 * 60 # 1 hour

			DEPLOY_REGEX = /\A\s*(re|)deploy(\sme|)/i
			route(DEPLOY_REGEX, command: true, help: { deploy: '_Deploy your Stacks_' }) do |context|
				secure_method_invoker(context, method(:handle_deploy), options_parser: Trollop::Parser.new {
					banner '*Usage:* _deploy <options>_'
					opt :stack, 'Stack name', type: :string, short: 's'
					opt :environment, 'Environment', type: :string, short: 'e'
					opt :services, 'Services (comma-separated list)', type: :strings, short: 'v'
					opt :wait, 'Wait for the stack to become available (if it is busy)', default: true
				})
			end

			def handle_deploy(options = {})
				stack_name = options[:stack]
				environment = options[:environment]
				services = options[:services]
				wait = options[:wait]

				raise Trollop::CommandlineError.new if stack_name.nil? || stack_name.empty?
				prepare_for_deploy(stack_name, environment, services, wait)
			end

			private

			def prepare_for_deploy(stack_name, environment, services, wait)
				# try get the stack
				client = Models::ApiClient.new
				stacks = client.get_stacks(stack_name: stack_name, environment: environment)
				reply(title: 'No matching stacks', color: Colors::RED) and return if stacks.empty?
				reply(title: 'Too many matching stacks', color: Colors::RED) and return if stacks.count > 1
				stack = stacks.first

				if stack.active?
					if wait
						reply(text: '*Stack is busy* (_Cloud 66_) - queued for deploy', color: Colors::GREEN)
						wait_for_stack(stack)
					else
						reply(text: '*Stack is busy* (_Cloud 66_)', color: Colors::ORANGE) and return
						return
					end
				elsif stack.custom_active?
					if wait
						reply(text: '*Stack is busy* (_custom url_) - queued for deploy', color: Colors::GREEN)
						wait_for_stack(stack)
					else
						reply(text: '*Stack is busy* (_custom url_)', color: Colors::ORANGE) and return
						return
					end
				end

				# NOTE: there is no distributed mutex, so it is possible that the stack becomes active
				# between the last step and here. However for the initial purposes of this bot that is not a problem
				perform_deploy(stack, services)
			end

			def wait_for_stack(stack)
				now = Time.new
				final_time = now + WAIT_TIMEOUT
				client = Models::ApiClient.new
				while stack.active? || stack.custom_active?
					raise 'Timeout while waiting for stack' if Time.new > final_time
					sleep(WAIT_CHECK_FREQ)
					stack = client.get_stack(stack.id)
				end
				return stack
			end

			def perform_deploy(stack, services)
				client = Models::ApiClient.new
				deploy_started = client.deploy(stack.id, services)
				if deploy_started
					reply(text: "*#{stack.name}:* Deploy started", color: Colors::BLUE)
					sleep(10)
					stack = client.get_stack(stack.id)
					stack = wait_for_stack(stack)
					reply(text: "*#{stack.name}:* Deploy complete", color: stack.notify_color)
				else
					reply(text: "*#{stack.name}:* Deploy was enqueued at Cloud 66 (as another deploy had just started); unable to track status", color: Colors::ORANGE)
				end
			end
		end
		Lita.register_handler(Deployer)
	end
end
