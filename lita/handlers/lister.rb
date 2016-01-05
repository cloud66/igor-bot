require 'httparty'
require 'time'

module Lita
	module Handlers
		class Lister < AbstractHandler

			LIST_REGEX = /\A(list|get|show|find|stacks)(\sstacks|\sall|\sall\sstacks|)/i
			route(LIST_REGEX, command: true, help: { deployer: 'list: List!' }) do |context|
				secure_method_invoker(context, method(:list_stacks), options_parser: Trollop::Parser.new {
					opt :stack, 'Stack', type: :string
					opt :environment, 'Environment', type: :string
				})
			end

			def list_stacks(options = {})
				client = Models::ApiClient.new
				stacks = client.get_stacks(stack: options[:stack], environment: options[:environment])
				reply(title: 'No matching stacks') if stacks.empty?

				attachments = []
				stacks.each do |stack|
					if stack.active?
						color = '#0000ff'
					elsif stack.status == :error
						color = :danger
					elsif stack.status == :unrecoverable
						color = '#000000'
					elsif stack.status == :impaired
						color = :warning
					else
						color = :good
					end
					attachments << {
						color: color,
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
