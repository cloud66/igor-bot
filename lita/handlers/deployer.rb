require 'httparty'
require_relative('../extensions/boolean_extensions')

module Lita
	module Handlers
		class Deployer < Lita::Handler

			WARNING_MOD = 10
			DEPLOY_PREFIX = 'igor_deployer'
			STAGING_WORKERS_URL = 'https://stage.cloud66.com/api/tooling/igor/sidekiq/stats.json'
			PROD_STACK_CHECK_URL = 'https://app.cloud66.com/api/tooling/igor/stack_busy'
			DEPLOY_REGEX = /\A\s*((?<force>force)\s|)(re|)deploy(\sme\s|\s)(?<stack_name>[a-z-_]+)(::(?<service_name>[a-z-_,]+)|)(\s(now|immediately)|\s(?<later>asap|soon|later)|)\s*\z/i
			STOP_REGEX = /\A(end|stop|cancel|quit|kill|terminate|end)\sdeploy(|ing|s|ment|ments)\z/i

			route(DEPLOY_REGEX, :do_deploy, command: true, help: { deployer: "deploy: Deploy!\nMore info!" })
			route(STOP_REGEX, :stop_deploy, command: true, help: { deployer: 'stop deploy: Stop all pending deploys!' })

			def do_deploy(context)
				return unless context.message.command?

				match_data = DEPLOY_REGEX.match(context.message.body)
				_stack_name = match_data[:stack_name]
				_service_name = match_data[:service_name]
				_force = !match_data[:force].nil?
				_later = !match_data[:later].nil?

				deploy(context, stack_name: _stack_name, service_name: _service_name, force: _force, later: _later)
			end

			def stop_deploy(context)
				return unless context.message.command?

				keys_wildcard = "*#{DEPLOY_PREFIX}.*"
				context.reply "DEBUG: #{keys_wildcard}"
				flagged = false
				redis.keys(keys_wildcard).each do |key|
					context.reply "DEBUG: #{key}"
					if redis.get(key) == 'true'
						flagged = true
						redis.set(key, 'false')
						context.reply 'DEBUG: Set key to false'
					end
				end

				context.reply 'Attempting to stop...' if flagged
			end

			private

			def deploy(context, stack_name:, service_name:, force:, later:)
				context.reply 'No no no... need to know what stack to deploy! hur hur hur!' and return if stack_name.nil? || stack_name.empty?
				context.reply 'No no no... force or wait? Can\'t do both! hur hur hur!' and return if force && asap

				stack_envs = ENV.keys.select { |stack_env| stack_env =~ /^#{stack_name}.*_hook/i }
				context.reply "No no no... no stack found for \"#{stack_name}\"" and return if stack_envs.nil? || stack_envs.empty?
				context.reply "No no no... more than one stack found for \"#{stack_name}\"" and return if stack_envs.size > 1
				stack_env = stack_envs.first
				redeployment_hook_url = ENV.fetch(stack_env)

				stack_name = stack_env.gsub(/_HOOK$/, '')
				redeployment_hook_url = "#{redeployment_hook_url}?services=#{service_name}" unless service_name.nil?

				deploy_key = "#{DEPLOY_PREFIX}.#{stack_env}"
				exists = redis.get(deploy_key)
				context.reply "No no no... an igor deploy for #{stack_name} is already waiting..." and return if exists == 'true'

				# register this deploy
				redis.set(deploy_key, 'true')

				unless force
					worker_status = get_worker_status(stack_env)
					deploy_status = get_deploy_status(redeployment_hook_url)
					if worker_status[:is_busy] || deploy_status[:is_busy]
						if later
							context.reply "#{stack_name} is busy... I'll deploy it as soon as it's done! Hur hur hur!"
							iterations = 0
							while worker_status[:is_busy] || deploy_status[:is_busy]
								iterations += 1
								sleep(20)
								worker_status = get_worker_status(stack_env)
								deploy_status = get_deploy_status(redeployment_hook_url)

								context.reply 'No no no... something is wrong! Waited more that 10 minutes...!' and return if iterations > 30

								its_a_go = redis.get(deploy_key)
								if its_a_go == 'false'
									redis.del(deploy_key)
									context.reply "#{stack_name} deploy cancelled! Hur hur hur"
									return
								end
							end
						else
							context.reply "No no no... #{stack_name} is busy on prod... not deploying!" and return if deploy_status[:is_busy]
							context.reply "No no no... #{stack_name} has busy workers... not deploying!" and return if worker_status[:is_busy]
						end
					end

					context.reply "Hmmmmm... #{stack_name} - #{worker_status[:error]}" unless worker_status[:error].nil?
					context.reply "Hmmmmm... #{stack_name} - #{deploy_status[:error]}" unless deploy_status[:error].nil?
				end

				redis.set(deploy_key, 'false')
				http_resp = HTTParty.post(redeployment_hook_url, {}) rescue nil
				if http_resp.nil?
					context.reply "No no no... got an unhandled exception response from the #{stack_name} web hook!"
				elsif http_resp.code != 200
					context.reply "No no no... got a non-200 response from the #{stack_name} web hook!"
				else
					if service_name.nil?
						context.reply "Whoop whoop! #{stack_name} deploy started! Hur hur hur"
					else
						context.reply "Whoop whoop! #{stack_name} (#{service_name}) deploy started! Hur hur hur"
					end

					# wait for deploy to start
					sleep(10)

					# wait for deploy to end
					iterations = 0
					deploy_status = get_deploy_status(redeployment_hook_url)
					while deploy_status[:is_busy]
						iterations += 1
						sleep(20)
						deploy_status = get_deploy_status(redeployment_hook_url)
						context.reply 'No no no... something is wrong! Waited more that 10 minutes...!' and return if iterations > 20
					end
					context.reply "Wooohooo #{stack_name} finished deploying!"
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
					return { is_busy: false, error: 'Could not get the deploy state... continuing!' }
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
					return { is_busy: false, error: 'Could not get the worker state... continuing!' }
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


		end
		Lita.register_handler(Deployer)
	end
end
