module Lita
	module Handlers
		class Clapper < Lita::Handler

			route(/^clap/i, command: true, help: { clapper: 'Gives you the clap' }) do |context|
				insecure_method_invoker(context, method(:clap))
			end

			def clap
				reply_core "clap clap clap clap clap... yes... you've got the clap now"
			end
		end

		Lita.register_handler(Clapper)
	end
end
