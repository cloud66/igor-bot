require 'httparty'

module Lita
	module Handlers
		class AbstractHandler < Lita::Handler
			attr_accessor :context

			protected

			def secure_method_invoker(context, lambda)
				@context = context
				return unless @context.message.command?
				unless Models::RegistrationManager.instance.is_registered?
					message = "To authorize this Cloud 66 Slack-Bot\n\n1) Get your access token from #{Models::RegistrationManager::AUTH_URL}\n2) Run: #{robot.mention_name} register <access token>"
					reply_core(title: 'Not Authorized!', color: :warning, message: message)
					return
				end
				lambda.call
			end

			def insecure_method_invoker(context, lambda)
				@context = context
				return unless @context.message.command?
				lambda.call
			end

			def check_registration

			end

			# optional colors [:good, :warning, :danger]
			def reply_core(title: nil, color: '', message: nil, fallback: nil)
				fallback = fallback || message || title
				chat_service = Lita::Robot.new.chat_service
				chat_service.send_attachment(@context.message.source.room_object, [{ title: title, text: message, color: color, fallback: fallback }])
				@context.reply
			end
		end
	end
end


FUN_PREFIXES_POS = [
	'Yes maaaster.',
	'Okay, okaaay.',
	'I\'m on it!',
	'You\'re the bossss!',
	'Coming right up...',
	'Ok fiiiine...',
	'Why you asking me? Okaay fine...',
	'Do I have too? Okaay fine...',
	'Yay!',
	'Whoop whoop!'
]

FUN_PREFIXES_NEG = [
	'No no no!',
	'Uh uh can\'t do that!',
	'Sorry maaaster!',
	'Noooooooooo!',
	'That\'s a negatory!',
	'いいえ!'
]

FUN_SUFFIXES = [
	'Hur hur hur',
	'<hack> <cough> <cough> <splutter>',
	'Oooh a rat! Darn, now I\'m hungry',
	'Yay! Lightning! I\'ll get the kite',
	'Got any spare body parts you\'re not using?',
	'',
	'',
	'',
	'',
	''
]