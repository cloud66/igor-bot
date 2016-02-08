require 'httparty'
require 'trollop'
require 'shellwords'

module Lita
	module Handlers
		class AbstractHandler < Lita::Handler
			attr_accessor :context

			protected

			def secure_method_invoker(context, lambda, options_parser: nil)
				@context = context
				@redis = redis
				return unless @context.message.command?
				unless Models::RegistrationManager.instance.is_registered?
					text = "To authorize this Cloud 66 Slack-Bot\n\n1) Get your access token from #{Models::RegistrationManager.instance.registration_url}\n2) Run: #{robot.mention_name} register --code <access token>"
					fallback = 'Authorization required!'
					reply(title: 'Not Authorized!', color: Colors::ORANGE, text: text, fallback: fallback)
					return
				end
				method_invoker(lambda, options_parser)
			end

			def insecure_method_invoker(context, lambda, options_parser: nil)
				@context = context
				@redis = redis
				return unless @context.message.command?
				method_invoker(lambda, options_parser)
			end

			# optional colors see: Colors
			def reply(title: nil, color: '', text: nil, fallback: nil, fields: nil)
				fallback = fallback || text || title
				attachments = [
					{
						title: title,
						text: text,
						color: color,
						fallback: fallback,
						mrkdwn_in: ['text']
					}
				]
				reply_raw(attachments)
			end

			def reply_raw(attachments)
				chat_service = Lita::Robot.new.chat_service
				chat_service.send_attachment(@context.message.source.room_object, attachments)
				@context.reply
			end

			private

			def method_invoker(lambda, options_parser)
				if options_parser
					arguments = Shellwords.split(@context.message.body)
					options = options_parser.parse(arguments)
					lambda.call(options)
				else
					lambda.call
				end

			rescue Trollop::CommandlineError => exc
				if options_parser
					string_io = StringIO.new
					options_parser.educate(string_io)
					reply(color: Colors::ORANGE, text: string_io.string, fallback: string_io.string)
				else
					reply(title: 'Error!', color: Colors::RED, text: exc.message, fallback: exc.message)
				end
			rescue => exc
				reply(title: 'Error!', color: Colors::RED, text: exc.message, fallback: exc.message)
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