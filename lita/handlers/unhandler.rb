module Lita
  module Handlers
    class Unhandler < AbstractHandler

      on(:unhandled_message) do |context|
        secure_method_invoker(context, method(:handle_wrong_command))
      end

      def handle_wrong_command(options = {})
        text = "Sorry, I don’t understand this command! \"#{command_from_message}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!"
        reply(title: "Unknown command", color: Colors::ORANGE, text: text, fallback: "Sorry, I don't understand this command!")
      end

    end
    Lita.register_handler(Unhandler)
  end
end