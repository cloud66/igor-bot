module Lita
	module Handlers
		class Registrar < AbstractHandler

			REGISTER_REGEX = /\A(register|authorize|auth)/i
			route(REGISTER_REGEX, command: true, help: { register: 'Authorize the Cloud 66 Slack-Bot' }) do |context|
				insecure_method_invoker(context, method(:register), options_parser: Trollop::Parser.new {
					opt :code, 'Code', type: :string
				})
			end

			DEREGISTER_REGEX = /\A(deregister|de-register|deauthorize|de-authorize|deauth|de-auth)\z/i
			route(DEREGISTER_REGEX, command: true, help: { deregister: 'De-Authorize the Cloud 66 Slack-Bot' }) do |context|
				secure_method_invoker(context, method(:deregister))
			end

			def register(options = {})
				code = options[:code]
				warning = Models::RegistrationManager.instance.set_token_info(code)
				if warning
					reply(title: 'Authorisation Saved!', color: Colors::ORANGE, text: warning)
				else
					message = 'Authorization saved for this Cloud 66 Slack-Bot'
					reply(title: 'Authorisation Saved!', color: Colors::GREEN, text: message)
				end
			rescue => exc
				reply(title: 'Authorisation Error!', color: Colors::RED, text: exc.message)
			end

			def deregister(_ = {})
				Models::RegistrationManager.instance.delete_token_info
				message = 'Authorization removed for this Cloud 66 Slack-Bot'
				reply(title: 'Authorisation Removed!', color: Colors::GREEN, text: message)
			end
		end
		Lita.register_handler(Registrar)
	end
end
