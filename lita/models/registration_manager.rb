require 'singleton'
require 'json'
require 'fileutils'
require 'rubygems'

module Models
	class RegistrationManager
		attr_accessor :access_token

		TOKEN_LOCATION = "/opt/chat-ops-common/c66-token.json"
		APP_UID = '72677fe32373ec3351a64424a5129718fc9d06715cdbc8af16f5a412713e3b5c'
		APP_SECRET = 'a5b9ee72d0fceb9c1091e995f867d80e9abf28c164621569a8f3d704e8b5905c'

		def initialize
			load_c66_token_info(TOKEN_LOCATION)
		end

		def is_registered?
			return self.access_token
		end

		def load_c66_token_info(token_location)
			if File.exist?(token_location)
				config = JSON.parse(File.read(token_location)).symbolize_keys
				client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://stage.cloud66.com')
				self.access_token = OAuth2::AccessToken.new(client, config[:local_token])
			end
		rescue => exc
			return exc.message
		end

	end
end
