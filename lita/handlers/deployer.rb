require 'httparty'
require_relative('../extensions/boolean_extensions')

module Lita
	module Handlers
		class Deployer < Lita::Handler

			WARNING_MOD = 10
			DEPLOY_PREFIX = 'igor_deployer'
			STAGING_WORKERS_URL = 'https://stage.cloud66.com/api/tooling/igor/sidekiq/stats.json'
			PROD_STACK_CHECK_URL = 'https://app.cloud66.com/api/tooling/igor/stack_busy'
			DEPLOY_REGEX = /\A\s*((?<force>force)\s|)(re|)deploy(\sme\s|\s)(?<stack_name>[a-z-_]+)(::(?<service_name>[a-z-_,]+)|)(\s(now|immediately)|\s(?<later>asap|soon|later)|)(\s(?<fun>(fun|with\sfun))|)\s*\z/i
			STOP_REGEX = /\A(end|stop|cancel|quit|kill|terminate|end)\sdeploy(|ing|s|ment|ments)(\s(?<fun>(fun|with\sfun))|)\z/i

			route(DEPLOY_REGEX, :do_deploy, command: true, help: { deployer: "deploy: Deploy!\nMore info here!" })
			route(STOP_REGEX, :stop_deploy, command: true, help: { deployer: 'stop deploy: Stop all pending deploys!' })

			attr_accessor :fun,
						  :context,
						  :stack_name

			def do_deploy(context)
				@context = context
				return unless @context.message.command?

				match_data = DEPLOY_REGEX.match(@context.message.body)
				@fun = !match_data[:fun].nil?
				@stack_name = match_data[:stack_name]
				@service_name = match_data[:service_name]
				_force = !match_data[:force].nil?
				_later = !match_data[:later].nil?

				deploy(force: _force, later: _later)
			end

			def stop_deploy(context)
				@context = context
				return unless @context.message.command?

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

			def deploy(force:, later:)
				reply(:error, 'stack name is missing') and return if @stack_name.nil? || @stack_name.empty?
				reply(:error, 'use force OR wait, not both') and return if force && later

				stack_envs = ENV.keys.select { |stack_env| stack_env =~ /^#{@stack_name}.*_hook/i }
				reply(:error, 'stack not found') and return if stack_envs.nil? || stack_envs.empty?
				reply(:error, 'results in more than one stack match') and return if stack_envs.size > 1
				stack_env = stack_envs.first
				redeployment_hook_url = ENV.fetch(stack_env)

				@stack_name = stack_env.gsub(/_HOOK$/, '')
				redeployment_hook_url = "#{redeployment_hook_url}?services=#{@service_name}" unless @service_name.nil?

				deploy_key = "#{DEPLOY_PREFIX}.#{stack_env}"
				exists = redis.get(deploy_key)
				reply(:warn, 'already deploying') and return if exists == 'true'

				# register this deploy
				redis.set(deploy_key, 'true')

				unless force
					worker_status = get_worker_status(stack_env)
					deploy_status = get_deploy_status(redeployment_hook_url)
					if worker_status[:is_busy] || deploy_status[:is_busy]
						if later
							reply(:ok, 'queued')
							iterations = 0
							while worker_status[:is_busy] || deploy_status[:is_busy]
								iterations += 1
								sleep(20)
								worker_status = get_worker_status(stack_env)
								deploy_status = get_deploy_status(redeployment_hook_url)
								reply(:error, 'timed out after 10 minutes') and return if iterations > 30

								its_a_go = redis.get(deploy_key)
								if its_a_go == 'false'
									redis.del(deploy_key)
									reply(:ok, 'cancelled')
									return
								end
							end
						else
							reply(:error, 'busy') and return if deploy_status[:is_busy]
							reply(:error, 'workers busy') and return if worker_status[:is_busy]
						end
					end

					reply(:warn, worker_status[:error]) unless worker_status[:error].nil?
					reply(:warn, deploy_status[:error]) unless deploy_status[:error].nil?
				end

				redis.set(deploy_key, 'false')
				http_resp = HTTParty.post(redeployment_hook_url, {}) rescue nil
				if http_resp.nil?
					reply(:error, 'web-hook unhandled exception')
				elsif http_resp.code != 200
					reply(:error, 'web-hook non-200 response')
				else
					reply(:ok, 'deploying')

					# wait for deploy to start
					sleep(10)

					# wait for deploy to end
					iterations = 0
					deploy_status = get_deploy_status(redeployment_hook_url)
					while deploy_status[:is_busy]
						iterations += 1
						sleep(20)
						deploy_status = get_deploy_status(redeployment_hook_url)
						reply(:error, 'timed out after 10 minutes') and return if iterations > 30
					end
					reply(:ok, 'deployed')
				end
			ensure
				# always get rid of that redis key when done
				redis.del(deploy_key)
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

			def get_worker_status(stack_env)
				return { is_busy: false } if stack_env != 'STAGING_HOOK'
				http_resp = HTTParty.get(STAGING_WORKERS_URL) rescue nil
				if http_resp.nil? || http_resp.code != 200
					return { is_busy: false, error: 'worker state unavailable' }
				else
					params = http_resp.parsed_response
					worker_count = params['response']['workers_info'].size rescue 0
					if worker_count > 0
						return { is_busy: true }
					else
						return { is_busy: false }
					end
				end
			end

			# state :ok, :warn:, :error
			def reply(state, message)
				if @stack_name && @service_name
					header = "> #{@stack_name}::#{@service_name.upcase} "
				elsif @stack_name
					header = "> #{@stack_name} "
				else
					header = '> '
				end

				if state == :ok
					state_text = ''
				elsif state == :warning || state == :warn
					state_text = 'WARN: '
				elsif state == :error
					state_text = 'ERROR: '
				end

				@context.reply "#{header}#{state_text}#{message}"
			end

		end
		Lita.register_handler(Deployer)
	end
end
