require 'httparty'

module Lita
	module Handlers
		class Deployer < AbstractHandler

			DEPLOY_REGEX = /\A\s*(re|)deploy(\sme|)/i
			route(DEPLOY_REGEX, command: true, help: { deployer: "deploy: Deploy!\nMore info here!" }) do |context|
				secure_method_invoker(context, method(:start_deploy), options_parser: Trollop::Parser.new {
					opt :stack, 'Stack', type: :string
					opt :environment, 'Environment', type: :string
					opt :services, 'Services', type: :strings
					opt :wait, 'Wait if Busy'
				})
			end

			def start_deploy(options = {})
				stack = options[:stack]
				environment = options[:environment]
				services = options[:services]
				wait = options[:wait]
				deploy(stack, environment, services, wait)
			end

			def stop_deploy(context)
				@context = context
				return unless check_registration(@context)

				match_data = DEPLOY_REGEX.match(@context.message.body)
				@fun = !match_data[:fun].nil?

				keys_wildcard = "*#{DEPLOY_PREFIX}.*"
				flagged = false
				redis.keys(keys_wildcard).each do |key|
					if redis.get(key) == 'true'
						flagged = true
						redis.set(key, 'false')
					end
				end
				if flagged
					reply(:ok, 'sending stop signal')
				else
					reply(:ok, 'no deploys found')
				end
			end

			private

			def deploy(stack, environment, services, wait)
				reply(title: 'Stack name is missing', color: Colors::RED) and return if stack.nil? || stack.empty?

				# try get the stack
				client = Models::ApiClient.new
				stacks = client.get_stacks(stack: stack, environment: environment)
				reply(title: 'No matching stacks', color: Colors::RED) and return if stacks.empty?
				reply(title: 'Too many matching stacks', color: Colors::RED) and return if stacks.count > 1
				stack = stacks.first

				if stack.active?
					if wait
						reply(title: 'Stack is busy! (Source: Cloud 66)', color: Colors::ORANGE) and return

					else
						reply(title: 'Stack is busy! (Source: Cloud 66)', color: Colors::ORANGE) and return
						return
					end
				elsif stack.custom_active?
					if wait
						reply(title: 'Stack is busy! (Source: Custom URL)', color: Colors::ORANGE) and return

					else
						reply(title: 'Stack is busy! (Source: Custom URL)', color: Colors::ORANGE) and return
						return
					end
				end

				reply(title: 'We can deploy', color: Colors::GREEN) and return


			#
			#
			#
			#
			# 	stack_envs = ENV.keys.select { |stack_env| stack_env =~ /^#{@stack_name}.*_hook/i }
			# 	reply(:error, 'stack not found') and return if stack_envs.nil? || stack_envs.empty?
			# 	reply(:error, 'results in more than one stack match') and return if stack_envs.size > 1
			# 	stack_env = stack_envs.first
			# 	redeployment_hook_url = ENV.fetch(stack_env)
			#
			# 	@stack_name = stack_env.gsub(/_HOOK$/, '')
			# 	redeployment_hook_url = "#{redeployment_hook_url}?services=#{@service_name}" unless @service_name.nil?
			#
			# 	deploy_key = "#{DEPLOY_PREFIX}.#{stack_env}"
			# 	exists = redis.get(deploy_key)
			# 	reply(:warn, 'already deploying') and return if exists == 'true'
			#
			# 	# register this deploy
			# 	redis.set(deploy_key, 'true')
			#
			# 	unless force
			# 		worker_status = get_worker_status(stack_env)
			# 		deploy_status = get_deploy_status(redeployment_hook_url)
			# 		if worker_status[:is_busy] || deploy_status[:is_busy]
			# 			if later
			# 				reply(:ok, 'queued')
			# 				iterations = 0
			# 				while worker_status[:is_busy] || deploy_status[:is_busy]
			# 					iterations += 1
			# 					sleep(20)
			# 					worker_status = get_worker_status(stack_env)
			# 					deploy_status = get_deploy_status(redeployment_hook_url)
			# 					reply(:error, 'timed out after 10 minutes') and return if iterations > 30
			#
			# 					its_a_go = redis.get(deploy_key)
			# 					if its_a_go == 'false'
			# 						redis.del(deploy_key)
			# 						reply(:ok, 'cancelled')
			# 						return
			# 					end
			# 				end
			# 			else
			# 				reply(:error, 'busy') and return if deploy_status[:is_busy]
			# 				reply(:error, 'workers busy') and return if worker_status[:is_busy]
			# 			end
			# 		end
			#
			# 		reply(:warn, worker_status[:error]) unless worker_status[:error].nil?
			# 		reply(:warn, deploy_status[:error]) unless deploy_status[:error].nil?
			# 	end
			#
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
			end

			def get_deploy_status(redeploy_hook)
				redeploy_key = redeploy_hook.gsub(/^.*\//, '')
				redeploy_key = redeploy_key.gsub(/\?.*$/, '')
				check_url = "#{PROD_STACK_CHECK_URL}/#{redeploy_key}.json"

				http_resp = HTTParty.get(check_url) rescue nil
				if http_resp.nil? || http_resp.code != 200
					return { is_busy: false, error: 'busy state unavailable' }
				else
					params = http_resp.parsed_response
					is_busy = params['response']['is_busy']
					return { is_busy: is_busy }
				end
			end

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
