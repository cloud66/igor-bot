require 'singleton'
require 'json'
require 'fileutils'
require 'rubygems'

module Models
	class RegistrationManager
		attr_accessor :access_token

		TOKEN_LOCATION = "/opt/chat-ops-common/c66-token.json"
		APP_UID = "b5de172cffa26c681954c96adb55fd8d5d7c5298bcc7669e4969241fa92b413f"
		APP_SECRET = "1d639bc0b2296aebdb7f0737645545ea2506ca8d20d0f9e34d976ba704debf23"

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
