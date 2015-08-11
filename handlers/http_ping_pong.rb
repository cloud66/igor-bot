module Handlers
	class HttpPingPong < Lita::Handler
		http.get '/ping' do |request, response|
			response.body << 'pong'
		end
	end
end