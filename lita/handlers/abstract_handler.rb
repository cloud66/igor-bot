require 'httparty'
require 'trollop'
require 'shellwords'
require 'i18n'


module Lita
	module Handlers
		class AbstractHandler < Lita::Handler
			attr_accessor :context

			protected

			def secure_method_invoker(context, lambda, options_parser: nil)
				@redis = redis
				@context = context
				return unless message_from_context().command?
				return if self.robot.mention_name == message_from_context.user.mention_name
				unless ::Models::RegistrationManager.instance.is_registered?
					text = "To authorize this Cloud 66 Slack-Bot\n\n -Go the registration web page of your personnal bot"
					fallback = 'Authorization required!'
					reply(title: 'Not Authorized!', color: Colors::ORANGE, text: text, fallback: fallback)
					return
				end
				method_invoker(lambda, options_parser)
 			end

			def insecure_method_invoker(context, lambda, options_parser: nil)
				@redis = redis
				@context = context
				return unless message_from_context().command?
				method_invoker(lambda, options_parser)
			end

			# optional colors see: Colors
			def reply(title: nil, color: '', text: nil, fallback: nil, fields: nil, pretext: nil)
				fallback = fallback || text || title
				attachments = [
					{
						title: title,
						text: text,
						color: color,
						fallback: fallback,
						mrkdwn_in: ['text'],
						pretext: pretext
					}
				]
				reply_raw(attachments)
			end

			def reply_raw(attachments)
				# robot.send_messages(message_from_context.source, attachments)
				chat_service = robot.chat_service
				chat_service.send_attachment(message_from_context().source.room_object, attachments)
				# reply_from_context()
			end

			private

			def method_invoker(lambda, options_parser)
				if options_parser
					arguments = Shellwords.split(handle_slack_quotes(message_from_context().body))
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
 				if exc.is_a?(Trollop::HelpNeeded) && ["deploy", "redeploy"].include?(command_from_message)
					reply(title: "Help for #{command_from_message}", color: Colors::BLACK, text: "Refer to the documentation", fallback: exc.message)
				elsif exc.is_a?(Trollop::HelpNeeded) && ["stop", "cancel", "exit", "halt"].include?(command_from_message)
					reply(title: "Help for #{command_from_message}", color: Colors::BLACK, text: "Refer to the documentation", fallback: exc.message)
				elsif exc.is_a?(Trollop::HelpNeeded) && ["list", "get", "show", "find"].include?(command_from_message)
					reply(title: "Help for #{command_from_message}", color: Colors::BLACK, text: "Refer to the documentation", fallback: exc.message)
				elsif exc.is_a?(OAuth2::Error)
					reply(title: "Token error", color: Colors::RED, text: "The Cloud 66 token provided is not valid, please try re-register using the registration page.", fallback: exc.message)
				else
					reply(title: "Error", color: Colors::RED, text: exc.message, fallback: exc.message)
				end
			end

			def handle_slack_quotes(message)
				wrong_quotes1 = '“'
				wrong_quotes2 = '”'
				wrong_quotes1.force_encoding 'UTF-8'
				wrong_quotes2.force_encoding 'UTF-8'
				message.gsub(wrong_quotes1,'"')
				return message.gsub(wrong_quotes2,'"')
			end

			def message_from_context()
				if @context.respond_to?(:message)
					context_message = @context.message
				elsif @context.is_a?(Hash) && context[:message]
					context_message = @context[:message]
				end
			end

			# def reply_from_context()
			# 	if @context.respond_to?(:reply)
			# 		@context.reply
			# 	elsif @context.is_a?(Hash) && context[:reply]
			# 		@context[:reply]
			# 	end
			# end

			def command_from_message()
				Shellwords.split(message_from_context().body).first
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
