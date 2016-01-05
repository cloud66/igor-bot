require 'singleton'
require 'json'
require 'fileutils'
require 'rubygems'

module Models
	class RegistrationManager
		include ::Singleton
		attr_accessor :access_token

		TOKEN_LOCATION = "#{APP_ROOT_PATH}/config/.slack-bot-auth.json"
		APP_UID = '72677fe32373ec3351a64424a5129718fc9d06715cdbc8af16f5a412713e3b5c'
		APP_SECRET = 'a5b9ee72d0fceb9c1091e995f867d80e9abf28c164621569a8f3d704e8b5905c'

		def initialize
			load_token_info(TOKEN_LOCATION)
		end

		def is_registered?
			return !self.access_token.nil?
		end

		def registration_url
			client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://app.cloud66.com')
			return client.auth_code.authorize_url(:redirect_uri => 'urn:ietf:wg:oauth:2.0:oob', :scope => 'public admin redeploy jobs users')
		end

		def set_token_info(code)
			client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://app.cloud66.com')
			self.access_token = client.auth_code.get_token(code, :redirect_uri => 'urn:ietf:wg:oauth:2.0:oob')
			warning = save_token_info(TOKEN_LOCATION)
			return warning.nil? ? nil : "Warning: Persisting your token to disk failed due to: #{warning}"
		end

		def delete_token_info
			self.access_token = nil
			remove_token_info(TOKEN_LOCATION)
		end

		private

		def load_token_info(token_location)
			if File.exist?(token_location)
				config = JSON.parse(File.read(token_location)).symbolize_keys
				client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://app.cloud66.com')
				self.access_token = OAuth2::AccessToken.new(client, config[:local_token])
			end
		end

		def save_token_info(token_location)
			FileUtils.mkdir_p(File.dirname(token_location))
			File.open(token_location, 'w') do |f|
				token_json = { local_token: self.access_token.token }.to_json
				f.write(token_json)
			end
			return nil
		rescue => exc
			return exc.message
		end

		def remove_token_info(token_location)
			FileUtils.rm_f(token_location)
		end
	end
end