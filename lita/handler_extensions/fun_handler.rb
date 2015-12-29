module Lita
	module HandlerExtensions
		module FunHandler
			# state :ok, :warn:, :error
			def reply(state, message)
				if @stack_name && @service_name
					title = "#{@stack_name}::#{@service_name.upcase}"
				elsif @stack_name
					title = "#{@stack_name}"
				else
					title = ''
				end

				if state == :success
					color = 'good'
				elsif state == :warning || state == :warn
					color = 'warning'
				elsif state == :error
					color = 'danger'
				else
					color = ''
				end

				message = message.capitalize
				if @fun
					prefix = [:ok].include?(state) ? FUN_PREFIXES_POS.sample : FUN_PREFIXES_NEG.sample
					suffix = FUN_SUFFIXES.sample
					content = title.empty? ? message : "#{title} - #{prefix} #{message}. #{suffix}"
				else
					content = title.empty? ? message : "#{title} - #{message}"
				end

				chat_service = Lita::Robot.new.chat_service
				chat_service.send_attachment(@context.message.source.room_object, [{ title: content, color: color, fallback: content }])

				@context.reply
			end
		end
	end
end