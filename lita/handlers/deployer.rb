require 'httparty'
require_relative('../extensions/boolean_extensions')

module Lita
	module Handlers
		class Deployer < Lita::Handler

			WARNING_SECONDS = 30
			WARNING_MOD = 10
			DEPLOY_PREFIX = 'igor_deployer'
			STAGING_WORKERS_URL = 'https://stage.cloud66.com/api/tooling/igor/sidekiq/stats.json'
			# PROD_STACK_CHECK_URL = 'https://app.cloud66.com/api/tooling/igor/stack_busy'
			PROD_STACK_CHECK_URL = 'https://stage.cloud66.com/api/tooling/igor/stack_busy'


			# PROD_STACK_CHECK_URL = 'https://app.cloud66.com/api/tooling/igor/stack_busy'

			DEPLOY_REGEX = /\A\s*((?<force>force)\s|)(re|)deploy(\sme\s|\s)(?<stack_name>[a-z]+)(::(?<service_name>[a-z]+)|)(\s(now|immediately)|\s(?<later>asap|soon|later)|)\s*\z/i

			route(DEPLOY_REGEX, :do_deploy, command: true, help: { deployer: "deploy: Deploy!\nMore info!" })
			route(/\A(stop|cancel|quit|kill|terminate|end)\sdeploy(|ing|s|ment|ments)\z/i, :stop_deploy, command: true, help: { deployer: 'stop deploy: Stop all pending deploys!' })

			def do_deploy(context)
				return unless context.message.command?

				match_data = DEPLOY_REGEX.match(context.message.body)
				_stack_name = match_data[:stack_name]
				_service_name = match_data[:service_name]
				_force = !match_data[:force].nil?
				_later = !match_data[:later].nil?

				deploy(context, stack_name: _stack_name, service_name: _service_name, force: _force, later: _later)
			end

			def deploy(context, stack_name:, service_name:, force:, later:)
				context.reply 'No no no... need to know what stack to deploy! hur hur hur!' and return if stack_name.nil? || stack_name.empty?
				context.reply 'No no no... force or wait? Can\'t do both! hur hur hur!' and return if force && asap

				# stack_envs = ENV.keys.select { |stack_env| stack_env =~ /^#{stack_name}.*_hook/i }
				# context.reply "No no no... no stack found for \"#{stack_name}\"" and return if stack_envs.nil? || stack_envs.empty?
				# context.reply "No no no... more than one stack found for \"#{stack_name}\"" and return if stack_envs.size > 1
				# stack_env = stack_envs.first
				# redeployment_hook_url = ENV.fetch(stack_env)

				redeployment_hook_url = 'https://hooks.cloud66.com/stacks/redeploy/483c35f079c4f33aa2582ea085d17ae0/c4fbff2a726685f812b6eb16197c616f'
				stack_env = 'STAGING_HOOK'

				redeployment_hook_url = "#{redeployment_hook_url}?services=#{service_name}" unless service_name.nil?

				

				unless force
					worker_status = get_worker_status(stack_env)
					deploy_status = get_deploy_status(redeployment_hook_url)
					if worker_status[:is_busy] || deploy_status[:is_busy]
						if later
							iterations = 0
							while worker_status[:is_busy] || deploy_status[:is_busy]
								iterations += 1
								sleep(15)
								worker_status = get_worker_status(stack_env)
								deploy_status = get_deploy_status(redeployment_hook_url)
							end
						else
							if worker_status[:is_busy]
								context.reply "No no no... deploy for \"#{stack_name}\" is already in progress! (Use: \"igor force ...\" or \"igor deploy ... asap\")"
								return
							end
							if deploy_status[:is_busy]
								context.reply 'No no no... there are busy workers on staging... not deploying! (Use: "igor force ..." or "igor deploy ... asap" )'
								return
							end
						end
					end
				end


				# http_resp = HTTParty.post(redeployment_hook_url, {}) rescue nil
				# if http_resp.nil?
				# 	context.reply "No no no... got an unhandled exception response from the \"#{stack_name}\" web hook!"
				# elsif http_resp.code != 200
				# 	context.reply "No no no... got a non-200 response from the \"#{stack_name}\" web hook!"
				# else
				# 	context.reply "Whoop whoop \"#{stack_name}\" deploy started! Hur hur hur"
				# end


				#TODO wait for response

				# 	start_time = Time.new
				# 	redis.setex(deploy_key, WARNING_SECONDS, 'true')
				#
				# 	its_a_go = redis.get(deploy_key)
				# 	notified_at_zero = false
				#
				# 	while its_a_go == 'true'
				# 		elapsed_seconds = (Time.new - start_time).round
				# 		remaining_seconds = (WARNING_SECONDS - elapsed_seconds)
				# 		remaining_seconds = 0 if remaining_seconds < 0
				#
				# 		if remaining_seconds % WARNING_MOD == 0 && !notified_at_zero
				# 			context.reply "\"#{stack_name}\" deploying in #{WARNING_SECONDS - elapsed_seconds} seconds..."
				# 			notified_at_zero = true if remaining_seconds == 0
				# 		end
				#
				# 		sleep(1)
				# 		its_a_go = redis.get(deploy_key)
				# 	end
				#
				# 	if its_a_go == 'false'
				# 		redis.del(deploy_key)
				# 		context.reply "\"#{stack_name}\" deploy cancelled! Hur hur hur"
				# 		return
				# 	end
				# end

=begin
				# if this is staging, better check if anything is running (special case)
				unless force
					if stack_env == 'STAGING_HOOK'
						http_resp = HTTParty.get(STAGING_WORKERS_URL) rescue nil
						if http_resp.nil? || http_resp.code != 200
							context.reply 'Oh... could not get the busy worker count on staging... skipping this step'
						else
							params = http_resp.parsed_response
							worker_count = params['response']['workers_size'].to_i rescue 0
							if worker_count > 0
								context.reply "No no no... there are busy workers on staging... not deploying! (To ignore this use: force deploy  \"#{stack_name}\")"
								return
							end
						end
					end
				end
=end
			end

			# def stop_deploy(context)
			# 	return unless context.message.command?
			# 	keys_wildcard = "*#{DEPLOY_PREFIX}.*"
			# 	context.reply 'Attempting to stop...'
			# 	redis.keys(keys_wildcard).each do |key|
			# 		redis.set(key, 'false')
			# 	end
			# end

			private

			def get_deploy_status(redeploy_hook)
				redeploy_key = redeploy_hook.gsub(/^.*\//, '')
				redeploy_key = redeploy_key.gsub(/\?.*$/, '')
				check_url = "#{PROD_STACK_CHECK_URL}/#{redeploy_key}.json"

				http_resp = HTTParty.get(check_url) rescue nil
				if http_resp.nil? || http_resp.code != 200
					return { is_busy: false, error: 'Could not get the state... continuing!' }
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
					return { is_busy: false, error: 'Could not get the worker state on staging... continuing!' }
				else
					params = http_resp.parsed_response
					worker_count = params['response']['workers_info'].size rescue 0
					if worker_count > 0
						return { is_busy: false }
					else
						return { is_busy: true }
					end
				end
			end


		end
		Lita.register_handler(Deployer)
	end
end
