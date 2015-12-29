module Lita
	module Handlers
		class Registrar < AbstractHandler

			REGISTER_REGEX = /\A(register|authorize|auth)\s+(?<access_token>[a-z0-9]+)\z/i
			route(REGISTER_REGEX, command: true, help: { register: 'Authorize the Cloud 66 Slack-Bot' }) do |context|
				insecure_method_invoker(context, method(:register))
			end
			DEREGISTER_REGEX = /\A(deregister|de-register|deauthorize|de-authorize|deauth|de-auth)\z/i
			route(DEREGISTER_REGEX, command: true, help: { deregister: 'De-Authorize the Cloud 66 Slack-Bot' }) do |context|
				secure_method_invoker(context, method(:deregister))
			end

			def register
				access_token = REGISTER_REGEX.match(@context.message.body)[:access_token]
				Models::RegistrationManager.instance.set_token_info(access_token: access_token)
				message = 'Authorization saved for this Cloud 66 Slack-Bot'
				reply_core(title: 'Authorisation Saved!', color: :good, message: message)
			end

			def deregister
				Models::RegistrationManager.instance.delete_token_info
				message = 'Authorization removed for this Cloud 66 Slack-Bot'
				reply_core(title: 'Authorisation Removed!', color: :good, message: message)
			end
		end
		Lita.register_handler(Registrar)
	end
end
