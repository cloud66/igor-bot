require 'singleton'
require 'json'
require 'fileutils'
require 'rubygems'

module Models
	class RegistrationManager
		include ::Singleton
		attr_accessor :access_token

		#TOKEN_LOCATION = "#{APP_ROOT_PATH}/config/.slack-bot-auth.json"
		TOKEN_LOCATION = "/opt/chat-ops-common/c66-token.json"
		APP_UID = "b5de172cffa26c681954c96adb55fd8d5d7c5298bcc7669e4969241fa92b413f"
		APP_SECRET = "1d639bc0b2296aebdb7f0737645545ea2506ca8d20d0f9e34d976ba704debf23"

		def initialize
			puts('?')
			load_c66_token_info(TOKEN_LOCATION)
		end

		def is_registered?
			if File.exist?(TOKEN_LOCATION)
				load_c66_token_info(TOKEN_LOCATION)
				return !self.access_token.nil?
			else
				return false
			end

		end

		def registration_url
			client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://stage.cloud66.com')
			return client.auth_code.authorize_url(:redirect_uri => 'urn:ietf:wg:oauth:2.0:oob', :scope => 'public admin redeploy jobs users')
		end


		def set_token_info(code)
			client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://stage.cloud66.com')
			puts(code)
			self.access_token = client.auth_code.get_token(code, :redirect_uri => 'urn:ietf:wg:oauth:2.0:oob')
			warning = save_token_info(TOKEN_LOCATION)
			File.new("/opt/chat-ops-common/is-token", "w")
			return warning.nil? ? nil : "Warning: Persisting your token to disk failed due to: #{warning}"
		rescue => exc
			return puts(exc)
		end

		def delete_token_info
			self.access_token = nil
			remove_token_info(TOKEN_LOCATION)
		end


		def load_c66_token_info(token_location)
			if File.exist?(token_location)
				config = JSON.parse(File.read(token_location)).symbolize_keys
				local_token = config[:local_token]
				client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://stage.cloud66.com')
				self.access_token = OAuth2::AccessToken.new(client, config[:local_token])
				if File.exist?("/opt/chat-ops-common/is-token")
				else
					puts('eho')
					set_token_info(local_token);
				end
			end
		rescue => exc
			return exc.message
		end

		private

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

		# def load_slack_token_info(token_location)
		# 	if File.exist?(token_location)
		# 		config = File.read(token_location)
		# 		# client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://stage.cloud66.com')
		# 		# self.access_token = OAuth2::AccessToken.new(client, config[:local_token])
		# 	end
		# end
	end
end
