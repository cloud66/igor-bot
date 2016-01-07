require 'httparty'
require 'time'

module Lita
	module Handlers
		class Lister < AbstractHandler

			LIST_REGEX = /\A(list|get|show|find|stacks)(\sstacks|\sall|\sall\sstacks|)/i
			route(LIST_REGEX, command: true, help: { list: '_List your Stacks_' }) do |context|
				secure_method_invoker(context, method(:handle_list), options_parser: Trollop::Parser.new {
					banner '*Usage:* _list <options>_'
					opt :stack, 'Stack', type: :string, short: 's'
					opt :environment, 'Environment', type: :string, short: 'e'
				})
			end

			def handle_list(options = {})
				client = Models::ApiClient.new
				stacks = client.get_stacks(stack_name: options[:stack], environment: options[:environment])
				reply(title: 'No matching stacks') if stacks.empty?

				attachments = []
				stacks.each do |stack|
					attachments << {
						color: stack.notify_color,
						text: "*#{stack.name}* _#{stack.environment}_ (#{stack.framework.capitalize}/#{stack.cloud}) *Last Activity:* _#{stack.last_activity_text}_",
						mrkdwn_in: ['text'],
						fallback: 'Listing stacks'
					}
				end
				reply_raw(attachments)
			end
		end
		Lita.register_handler(Lister)
	end
end
