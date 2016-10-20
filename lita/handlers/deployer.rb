require 'httparty'
require 'json'

module Lita
	module Handlers
		class Deployer < AbstractHandler
			WAIT_CHECK_FREQ = 30 # 30 seconds
			WAIT_TIMEOUT = 60 * 60 # 1 hour





			on(:unhandled_message) do |context|
				secure_method_invoker(context, method(:handle_wrong_command))
			end

			DEPLOY_REGEX = /\A\s*(re|)deploy(\sme|)/i
			route(DEPLOY_REGEX, command: true, help: { deploy: '_Deploy your Stacks_' }) do |context|
				secure_method_invoker(context, method(:handle_deploy), options_parser: Trollop::Parser.new {
					banner '*Usage:* _deploy <options>_'
					opt :stack, 'Stack name', type: :string, short: 's'
					opt :environment, 'Environment', type: :string, short: 'e'
					opt :services, 'Services (multiple allowed)', type: :string, multi: true, short: 'v'
					opt :wait, 'Wait for the stack to become available (if it is busy)', default: true
				})
			end
			CANCEL_REGEX = /\A\s*(stop|cancel|exit|halt)(\s+(re|)deploy(\sme|)|)/i
			route(CANCEL_REGEX, command: true, help: { cancel: '_Cancel your Queued Deploys_' }) do |context|
				secure_method_invoker(context, method(:handle_cancel), options_parser: Trollop::Parser.new {
					banner '*Usage:* _cancel <options>_'
          opt :stack, 'Stack name', type: :string, short: 's'
          opt :environment, 'Environment', type: :string, short: 'e'
          opt :services, 'Services (multiple allowed)', type: :string, multi: true, short: 'v'
          opt :wait, 'Wait for the stack to become available (if it is busy)', default: true
				})
			end

			def handle_deploy(options = {})
				stack_name = options[:stack]
				environment = options[:environment]
				services = options[:services] || []
				wait = options[:wait]
				raise Trollop::CommandlineError.new if stack_name.nil? || stack_name.empty?
				prepare_for_deploy(stack_name, environment, services, wait)
			end

			def handle_cancel(options = {})
				stack_name = options[:stack]
				environment = options[:environment]
				raise Trollop::CommandlineError.new if stack_name.nil? || stack_name.empty?
				prepare_for_cancel(stack_name, environment)
			end


			def handle_wrong_command(options = {})
        text = "Sorry, I don’t understand this command! \"#{command_from_message}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!"
        reply(title: "Unknown command", color: Colors::ORANGE, text: text, fallback: string_io.string)
			end


			private

			def prepare_for_deploy(stack_name, environment, services, wait)
				# try get the stack
				client = Models::ApiClient.new
				stacks = client.get_stacks(stack_name: stack_name, environment: environment)
				reply(title: 'No matching stacks', color: Colors::RED) and return if stacks.empty?
				reply(title: 'Too many matching stacks', color: Colors::RED) and return if stacks.count > 1
				stack = stacks.first

				# validate services
				unless services.empty?
					# deal with services params
					requested_names = services.map { |svc| svc.gsub(/:.*/, '') }.sort
					existing_names = client.get_stack_services(stack.id).map { |service| service.name }
					reply(text: "#{header(stack, services)} services not found", color: Colors::RED) and return if existing_names & requested_names != requested_names
				end

				status = get_local_status(stack)
				if [:queued, :deploying, :cancelling].include?(status)
					reply(text: "#{header(stack, services)} already #{status}", color: Colors::ORANGE)
					return
				end

				if stack.active?
					if wait
						reply(text: "#{header(stack, services)} busy (_Cloud 66_ checkup); Queued for later deploy", color: Colors::GREEN)
						set_local_status(stack, :queued)
						wait_for_stack(stack)
					else
						reply(text: "#{header(stack, services)} busy (_Cloud 66_ checkup); Exiting", color: Colors::ORANGE) and return
						set_local_status(stack, :none)
						return
					end
				elsif stack.custom_active?
					if wait
						reply(text: "#{header(stack, services)} busy (_custom url_ checkup); Queued for later deploy", color: Colors::GREEN)
						set_local_status(stack, :queued)
						wait_for_stack(stack)
					else
						reply(text: "#{header(stack, services)} busy (_custom url_ checkup); Exiting", color: Colors::ORANGE) and return
						set_local_status(stack, :none)
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

				# exit if its been cancelled
				if get_local_status(stack) == :cancelling
					reply(text: "#{header(stack, services)} deploy cancelled", color: Colors::GREEN)
					return
				end

				deploy_started = client.deploy(stack.id, services)
				if deploy_started
					set_local_status(stack, :deploying)
					reply(text: "#{header(stack, services)} deploy started", color: Colors::BLUE)
					sleep(10)
					stack = client.get_stack(stack.id)
					stack = wait_for_stack(stack)
					reply(text: "#{header(stack, services)} deploy complete", color: stack.notify_color)
				else
					reply(text: "#{header(stack, services)} deploy was enqueued at Cloud 66 (as another deploy had just started); unable to track status", color: Colors::ORANGE)
				end
			ensure
				set_local_status(stack, :none)
			end

			def prepare_for_cancel(stack_name, environment)
				# try get the stack
				stack = Stack.new(name: stack_name, environment: environment)
				status = get_local_status(stack)
				if status == :queued
					set_local_status(stack, :cancelling)
					reply(text: "#{header(stack)} trying to cancel deployment", color: Colors::BLUE)
				elsif status == :deploying
					reply(text: "#{header(stack)} stack already started deploying", color: Colors::ORANGE)
				elsif status == :cancelling
					reply(text: "#{header(stack)} still being cancelled (please wait)", color: Colors::ORANGE)
				else
					reply(text: "#{header(stack)} not currently queued", color: Colors::GREEN)
				end
			end

			def get_local_status(stack)
				deploy_key = "handler:deployer:#{stack.name}:#{stack.environment}"
				status = @redis.get(deploy_key)
				return :none if status.nil?
				return status.to_sym
			end

			# status (:none, :deploying, :queued, :cancelling)
			def set_local_status(stack, status)
				deploy_key = "handler:deployer:#{stack.name}:#{stack.environment}"
				if status == :none
					@redis.del(deploy_key)
				else
					@redis.setex(deploy_key, WAIT_TIMEOUT, status)
				end
			end

			def header(stack, services = nil)
				return "*#{stack.name} (_#{services.join('|')}_)* - " unless services.empty?
				return "*#{stack.name}* -"
			end
		end
		Lita.register_handler(Deployer)
	end
end
