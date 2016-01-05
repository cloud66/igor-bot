require 'httparty'

module Lita
	module Handlers
		class Deployer < AbstractHandler

			WAIT_CHECK_FREQ = 30 # 30 seconds
			WAIT_TIMEOUT = 60 * 60 # 1 hour

			DEPLOY_REGEX = /\A\s*(re|)deploy(\sme|)/i
			route(DEPLOY_REGEX, command: true, help: { deployer: "deploy: Deploy!\nMore info here!" }) do |context|
				secure_method_invoker(context, method(:handle_deploy), options_parser: Trollop::Parser.new {
					opt :stack, 'Stack', type: :string
					opt :environment, 'Environment', type: :string
					opt :services, 'Services', type: :strings
					opt :wait, default: true
				})
			end

			def handle_deploy(options = {})
				stack = options[:stack]
				environment = options[:environment]
				services = options[:services]
				wait = options[:wait]
				prepare_for_deploy(stack, environment, services, wait)
			end

			private

			def prepare_for_deploy(stack_name, environment, services, wait)
				reply(title: 'Stack name is missing', color: Colors::RED) and return if stack_name.nil? || stack_name.empty?

				# try get the stack
				client = Models::ApiClient.new
				stacks = client.get_stacks(stack_name: stack_name, environment: environment)
				reply(title: 'No matching stacks', color: Colors::RED) and return if stacks.empty?
				reply(title: 'Too many matching stacks', color: Colors::RED) and return if stacks.count > 1
				stack = stacks.first

				if stack.active?
					if wait
						reply(text: '*Stack is busy* (source: _Cloud 66_) - waiting', color: Colors::GREEN)
						wait_for_stack(stack)
					else
						reply(text: '*Stack is busy* (source: _Cloud 66_)', color: Colors::ORANGE) and return
						return
					end
				elsif stack.custom_active?
					if wait
						reply(text: '*Stack is busy* (source: _custom url_)', color: Colors::GREEN)
						wait_for_stack(stack)
					else
						reply(text: '*Stack is busy* (source: _custom url_)', color: Colors::ORANGE) and return
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
				client.deploy(stack.id, services)
				stack = wait_for_stack(stack)
				reply(text: 'Deploy complete', color: stack.notify_color)
			end

			# 	redis.set(deploy_key, 'false')
			# 	http_resp = HTTParty.post(redeployment_hook_url, {}) rescue nil
			# 	if http_resp.nil?
			# 		reply(:error, 'web-hook unhandled exception')
			# 	elsif http_resp.code != 200
			# 		reply(:error, 'web-hook non-200 response')
			# 	else
			# 		reply(:ok, 'deploying')
			#
			# 		# wait for deploy to start
			# 		sleep(10)
			#
			# 		# wait for deploy to end
			# 		iterations = 0
			# 		deploy_status = get_deploy_status(redeployment_hook_url)
			# 		while deploy_status[:is_busy]
			# 			iterations += 1
			# 			sleep(20)
			# 			deploy_status = get_deploy_status(redeployment_hook_url)
			# 			reply(:error, 'timed out after 10 minutes') and return if iterations > 30
			# 		end
			# 		reply(:success, 'deployed')
			# 	end
			# ensure
			# 	# always get rid of that redis key when done
			# 	redis.del(deploy_key)
		# end

		private

		# # state :success, :ok, :warn:, :error
		# def reply(state, message)
		# 	if @stack_name && @service_name
		# 		title = "#{@stack_name}::#{@service_name.upcase}"
		# 	elsif @stack_name
		# 		title = "#{@stack_name}"
		# 	else
		# 		title = ''
		# 	end
		#
		# 	if state == :success
		# 		color = 'good'
		# 	elsif state == :warning || state == :warn
		# 		color = 'warning'
		# 	elsif state == :error
		# 		color = 'danger'
		# 	else
		# 		color = ''
		# 	end
		#
		# 	message = message.capitalize
		# 	if @fun
		# 		prefix = [:ok].include?(state) ? FUN_PREFIXES_POS.sample : FUN_PREFIXES_NEG.sample
		# 		suffix = FUN_SUFFIXES.sample
		# 		content = title.empty? ? message : "#{title} - #{prefix} #{message}. #{suffix}"
		# 	else
		# 		content = title.empty? ? message : "#{title} - #{message}"
		# 	end
		#
		# 	chat_service = Lita::Robot.new.chat_service
		# 	chat_service.send_attachment(@context.message.source.room_object, [{ title: content, color: color, fallback: content }])
		# 	@context.reply
		# end

	end
	Lita.register_handler(Deployer)
end
end
