require 'httparty'

module Lita
	module Handlers
		class Deployer < Lita::Handler

			WARNING_SECONDS = 30
			WARNING_MOD = 10
			DEPLOY_PREFIX = 'igor_deployer'
			STAGING_WORKERS_URL = 'https://stage.cloud66.com/api/tooling/sidekiq/stats.json'

			route(/\Adeploy\s+/i, :normal_deploy, command: true, help: { deployer: 'deploy: Start deploys!' })
			route(/\Aforce\sdeploy\s+/i, :force_deploy, command: true, help: { deployer: 'force deploy: Start deploys (ignore any checks)!' })
			route(/\A(stop|cancel|quit)\sdeploy(|s|ment|ments)\z/i, :stop_deploy, command: true, help: { deployer: 'stop deploy: Stop all pending deploys!' })

			def force_deploy(context)
				_args = context.args[1..-1]
				deploy(context, force: true, args: _args)
			end

			def normal_deploy(context)
				_args = context.args
				deploy(context, force: false, args: _args)
			end

			def deploy(context, force:, args:)
				return unless context.message.command?

				args = args.reject { |arg| arg =~ /^me$/ }
				stack_name = args[0]
				context.reply 'No no no... what is a me? hur hur hur!' and return if stack_name.nil? || stack_name.empty?
				context.reply 'No no no... too many arguments! hur hur hur!' and return if args.size > 3

				if args[-1] == 'now'
					deploy_immediately = true
					args = args[0..-2]
				else
					deploy_immediately = false
				end

				if args.size > 1
					service_args = args[1]
				else
					service_args = ''
				end

				ENV['STAGING_HOOK'] = 'babana'

				stack_envs = ENV.keys.select { |stack_env| stack_env =~ /^#{stack_name}.*_hook/i }
				context.reply "No no no... no stack found for \"#{stack_name}\"" and return if stack_envs.nil? || stack_envs.empty?
				context.reply "No no no... more than one stack found for \"#{stack_name}\"" and return if stack_envs.size > 1

				stack_env = stack_envs.first
				redeployment_hook_url = ENV.fetch(stack_env)
				redeployment_hook_url = "#{redeployment_hook_url}?services=#{service_args}" unless service_args.empty?

				deploy_key = "#{DEPLOY_PREFIX}.#{stack_env}"
				exists = redis.get(deploy_key)
				context.reply "No no no... deploy for \"#{stack_name}\" already in progress" and return if exists

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

				unless deploy_immediately
					context.reply "Yesssir! Deploying \"#{stack_name}\" in #{WARNING_SECONDS} seconds... (unless you tell me \"stop deploy\")"
					start_time = Time.new
					redis.setex(deploy_key, WARNING_SECONDS, 'true')

					its_a_go = redis.get(deploy_key)
					notified_at_zero = false

					while its_a_go == 'true'
						elapsed_seconds = (Time.new - start_time).round
						remaining_seconds = (WARNING_SECONDS - elapsed_seconds)
						remaining_seconds = 0 if remaining_seconds < 0

						if remaining_seconds % WARNING_MOD == 0 && !notified_at_zero
							context.reply "\"#{stack_name}\" deploying in #{WARNING_SECONDS - elapsed_seconds} seconds..."
							notified_at_zero = true if remaining_seconds == 0
						end

						sleep(1)
						its_a_go = redis.get(deploy_key)
					end

					if its_a_go == 'false'
						redis.del(deploy_key)
						context.reply "\"#{stack_name}\" deploy cancelled! Hur hur hur"
						return
					end
				end

				http_resp = HTTParty.post(redeployment_hook_url, {})
				if http_resp.code != 200
					context.reply "No no no... got a non-200 response from the \"#{stack_name}\" web hook!"
				else
					context.reply "Whoop whoop \"#{stack_name}\" deploy started! Hur hur hur"
				end
			end

			def stop_deploy(context)
				return unless context.message.command?
				keys_wildcard = "*#{DEPLOY_PREFIX}.*"
				context.reply 'Attempting to stop...'
				redis.keys(keys_wildcard).each do |key|
					redis.set(key, 'false')
				end
			end

		end

		Lita.register_handler(Deployer)
	end
end
